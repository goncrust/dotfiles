#include "event.h"

extern int g_connection;
extern struct event_loop g_event_loop;
extern struct process_manager g_process_manager;
extern struct window_manager g_window_manager;
extern bool g_mission_control_active;
extern void *g_workspace_context;

struct event *event_create(struct event_loop *event_loop, enum event_type type, void *context)
{
    struct event *event = memory_pool_push(&event_loop->pool, struct event);
    event->type = type;
    event->context = context;
    event->param1 = 0;
    event->info = 0;
    return event;
}

struct event *event_create_p1(struct event_loop *event_loop, enum event_type type, void *context, int param1)
{
    struct event *event = memory_pool_push(&event_loop->pool, struct event);
    event->type = type;
    event->context = context;
    event->param1 = param1;
    event->info = 0;
    return event;
}

void event_destroy(struct event_loop *event_loop, struct event *event)
{
    switch (event->type) {
    default: break;

    case APPLICATION_TERMINATED: {
        process_destroy(event->context);
    } break;
    case WINDOW_CREATED: {
        CFRelease(event->context);
    } break;
    }
}

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_LAUNCHED)
{
    struct process *process = context;

    if (process->terminated) {
        debug("%s: %s (%d) terminated during launch\n", __FUNCTION__, process->name, process->pid);
        window_manager_remove_lost_front_switched_event(&g_window_manager, process->pid);
        return EVENT_FAILURE;
    }

    if (!workspace_application_is_observable(process)) {
        debug("%s: %s (%d) is not observable, subscribing to activationPolicy changes\n", __FUNCTION__, process->name, process->pid);
        workspace_application_observe_activation_policy(g_workspace_context, process);
        return EVENT_FAILURE;
    }

    if (!workspace_application_is_finished_launching(process)) {
        debug("%s: %s (%d) is not finished launching, subscribing to finishedLaunching changes\n", __FUNCTION__, process->name, process->pid);
        workspace_application_observe_finished_launching(g_workspace_context, process);
        return EVENT_FAILURE;
    }

    struct application *application = application_create(process);
    if (!application_observe(application)) {
        bool ax_retry = application->ax_retry;
        application_unobserve(application);
        application_destroy(application);

        debug("%s: could not observe notifications for %s (%d) (ax_retry = %d)\n", __FUNCTION__, process->name, process->pid, ax_retry);

        if (ax_retry) {
            __block ProcessSerialNumber psn = process->psn;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                struct process *_process = process_manager_find_process(&g_process_manager, &psn);
                if (!_process) return;

                struct event *event = event_create(&g_event_loop, APPLICATION_LAUNCHED, _process);
                event_loop_post(&g_event_loop, event);
            });
        }

        return EVENT_FAILURE;
    }


    debug("%s: %s (%d)\n", __FUNCTION__, process->name, process->pid);
    window_manager_add_application(&g_window_manager, application);
    window_manager_add_application_windows(&g_window_manager, application);

    if (window_manager_find_lost_front_switched_event(&g_window_manager, process->pid)) {
        struct event *event = event_create(&g_event_loop, APPLICATION_FRONT_SWITCHED, process);
        event_loop_post(&g_event_loop, event);
        window_manager_remove_lost_front_switched_event(&g_window_manager, process->pid);
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_TERMINATED)
{
    struct process *process = context;
    struct application *application = window_manager_find_application(&g_window_manager, process->pid);

    if (!application) {
        debug("%s: %s (%d) (not observed)\n", __FUNCTION__, process->name, process->pid);
        return EVENT_FAILURE;
    }

    debug("%s: %s (%d)\n", __FUNCTION__, process->name, process->pid);
    window_manager_remove_application(&g_window_manager, application->pid);

    int window_count = 0;
    struct window **window_list = window_manager_find_application_windows(&g_window_manager, application, &window_count);
    if (!window_list) goto end;

    for (int i = 0; i < window_count; ++i) {
        struct window *window = window_list[i];
        if (!window) continue;

        window_manager_remove_window(&g_window_manager, window->id);
        window_destroy(window);
    }

    free(window_list);

end:
    application_unobserve(application);
    application_destroy(application);

    return EVENT_SUCCESS;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_FRONT_SWITCHED)
{
    struct process *process = context;
    struct application *application = window_manager_find_application(&g_window_manager, process->pid);

    if (!application) {
        window_manager_add_lost_front_switched_event(&g_window_manager, process->pid);
        return EVENT_FAILURE;
    }

    struct event *de_event = event_create(&g_event_loop, APPLICATION_DEACTIVATED, (void *)(intptr_t) g_process_manager.front_pid);
    event_loop_post(&g_event_loop, de_event);

    struct event *re_event = event_create(&g_event_loop, APPLICATION_ACTIVATED, (void *)(intptr_t) process->pid);
    event_loop_post(&g_event_loop, re_event);

    debug("%s: %s (%d)\n", __FUNCTION__, process->name, process->pid);
    g_process_manager.front_pid = process->pid;

    return EVENT_SUCCESS;
}
#pragma clang diagnostic pop

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_ACTIVATED)
{
    struct application *application = window_manager_find_application(&g_window_manager, (pid_t)(intptr_t) context);
    if (!application) return EVENT_FAILURE;

    debug("%s: %s\n", __FUNCTION__, application->name);
    uint32_t application_focused_window_id = application_focused_window(application);
    if (!application_focused_window_id) {
        g_window_manager.focused_window_id = 0;
        g_window_manager.focused_window_psn = application->psn;
        return EVENT_SUCCESS;
    }

    struct window *window = window_manager_find_window(&g_window_manager, application_focused_window_id);
    if (!window) {
        window_manager_add_lost_focused_event(&g_window_manager, application_focused_window_id);
        return EVENT_SUCCESS;
    }

    g_window_manager.focused_window_id = application_focused_window_id;
    g_window_manager.focused_window_psn = application->psn;

    border_window_activate(window);

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_DEACTIVATED)
{
    struct application *application = window_manager_find_application(&g_window_manager, (pid_t)(intptr_t) context);
    if (!application) return EVENT_FAILURE;

    debug("%s: %s\n", __FUNCTION__, application->name);
    struct window *focused_window = window_manager_find_window(&g_window_manager, application_focused_window(application));
    if (focused_window) {
        border_window_deactivate(focused_window);
        if (!window_level_is_standard(focused_window) || !window_is_standard(focused_window)) {
            struct window *main_window = window_manager_find_window(&g_window_manager, application_main_window(application));
            if (main_window && main_window != focused_window) {
                border_window_deactivate(main_window);
            }
        }
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_VISIBLE)
{
    struct application *application = window_manager_find_application(&g_window_manager, (pid_t)(intptr_t) context);
    if (!application) return EVENT_FAILURE;

    debug("%s: %s\n", __FUNCTION__, application->name);
    application->is_hidden = false;

    int window_count = 0;
    struct window **window_list = window_manager_find_application_windows(&g_window_manager, application, &window_count);
    if (!window_list) return EVENT_SUCCESS;

    for (int i = 0; i < window_count; ++i) {
        struct window *window = window_list[i];
        if (!window) continue;

        if ((!window->is_minimized) &&
            (!window->is_fullscreen) &&
            (!window->is_minimized) &&
            (!window_is_fullscreen(window))) {
            border_window_show(window);
        }
    }

    free(window_list);
    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_HIDDEN)
{
    struct application *application = window_manager_find_application(&g_window_manager, (pid_t)(intptr_t) context);
    if (!application) return EVENT_FAILURE;

    debug("%s: %s\n", __FUNCTION__, application->name);
    application->is_hidden = true;

    int window_count = 0;
    struct window **window_list = window_manager_find_application_windows(&g_window_manager, application, &window_count);
    if (!window_list) return EVENT_SUCCESS;

    for (int i = 0; i < window_count; ++i) {
        struct window *window = window_list[i];
        if (!window) continue;
        border_window_hide(window);
    }

    free(window_list);
    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_CREATED)
{
    uint32_t window_id = ax_window_id(context);
    if (!window_id) return EVENT_FAILURE;

    struct window *existing_window = window_manager_find_window(&g_window_manager, window_id);
    if (existing_window) return EVENT_FAILURE;

    pid_t window_pid = ax_window_pid(context);
    if (!window_pid) return EVENT_FAILURE;

    struct application *application = window_manager_find_application(&g_window_manager, window_pid);
    if (!application) return EVENT_FAILURE;

    struct window *window = window_create(application, CFRetain(context), window_id);
    if (window_is_popover(window) || window_is_unknown(window)) {
        debug("%s: ignoring window %s %d\n", __FUNCTION__, window->application->name, window->id);
        window_manager_remove_lost_focused_event(&g_window_manager, window->id);
        window_destroy(window);
        return EVENT_FAILURE;
    }

    if (!window_observe(window)) {
        debug("%s: could not observe %s %d\n", __FUNCTION__, window->application->name, window->id);
        window_manager_remove_lost_focused_event(&g_window_manager, window->id);
        window_unobserve(window);
        window_destroy(window);
        return EVENT_FAILURE;
    }

    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);
    window_manager_add_window(&g_window_manager, window);

    if (window_manager_find_lost_focused_event(&g_window_manager, window->id)) {
        struct event *event = event_create(&g_event_loop, WINDOW_FOCUSED, (void *)(intptr_t) window->id);
        event_loop_post(&g_event_loop, event);
        window_manager_remove_lost_focused_event(&g_window_manager, window->id);
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_DESTROYED)
{
    uint32_t window_id = (uint32_t)(uintptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);
    if (!window) return EVENT_FAILURE;

    assert(!*window->id_ptr);
    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);
    window_unobserve(window);

    window_manager_remove_window(&g_window_manager, window->id);
    window_destroy(window);

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_FOCUSED)
{
    uint32_t window_id = (uint32_t)(intptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);

    if (!window) {
        window_manager_add_lost_focused_event(&g_window_manager, window_id);
        return EVENT_FAILURE;
    }

    if (!__sync_bool_compare_and_swap(window->id_ptr, &window->id, &window->id)) {
        debug("%s: %d has been marked invalid by the system, ignoring event..\n", __FUNCTION__, window_id);
        return EVENT_FAILURE;
    }

    if (window_is_minimized(window)) {
        window_manager_add_lost_focused_event(&g_window_manager, window->id);
        return EVENT_SUCCESS;
    }

    if (!application_is_frontmost(window->application)) {
        return EVENT_SUCCESS;
    }

    struct window *focused_window = window_manager_find_window(&g_window_manager, g_window_manager.focused_window_id);
    if (focused_window && focused_window != window) {
        border_window_deactivate(focused_window);
    }

    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);
    border_window_activate(window);

    if (window_level_is_standard(window) && window_is_standard(window)) {
        g_window_manager.focused_window_id = window->id;
        g_window_manager.focused_window_psn = window->application->psn;
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_MOVED)
{
    uint32_t window_id = (uint32_t)(intptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);
    if (!window) return EVENT_FAILURE;

    if (!__sync_bool_compare_and_swap(window->id_ptr, &window->id, &window->id)) {
        debug("%s: %d has been marked invalid by the system, ignoring event..\n", __FUNCTION__, window_id);
        return EVENT_FAILURE;
    }

    if (window->application->is_hidden) return EVENT_SUCCESS;

    if (!window->is_fullscreen) border_window_refresh(window);

    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_RESIZED)
{
    uint32_t window_id = (uint32_t)(intptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);
    if (!window) return EVENT_FAILURE;

    if (!__sync_bool_compare_and_swap(window->id_ptr, &window->id, &window->id)) {
        debug("%s: %d has been marked invalid by the system, ignoring event..\n", __FUNCTION__, window_id);
        return EVENT_FAILURE;
    }

    if (window->application->is_hidden) return EVENT_SUCCESS;

    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);

    bool is_fullscreen = window_is_fullscreen(window);

    if (!window->is_fullscreen && is_fullscreen) {
        border_window_hide(window);
    } else if (window->is_fullscreen && !is_fullscreen) {
        uint32_t did = window_display_id(window);

        while (display_manager_display_is_animating(did)) {

            //
            // NOTE(koekeishiya): Window has exited native-fullscreen mode.
            // We need to spin lock until the display is finished animating
            // because we are not actually able to interact with the window.
            //

            usleep(100000);
        }

        border_window_show(window);
    }

    window->is_fullscreen = is_fullscreen;

    if (!window->is_fullscreen) border_window_refresh(window);

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_MINIMIZED)
{
    uint32_t window_id = (uint32_t)(intptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);
    if (!window) return EVENT_FAILURE;

    if (!__sync_bool_compare_and_swap(window->id_ptr, &window->id, &window->id)) {
        debug("%s: %d has been marked invalid by the system, ignoring event..\n", __FUNCTION__, window_id);
        return EVENT_FAILURE;
    }

    debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);
    window->is_minimized = true;
    border_window_hide(window);

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_DEMINIMIZED)
{
    uint32_t window_id = (uint32_t)(intptr_t) context;
    struct window *window = window_manager_find_window(&g_window_manager, window_id);
    if (!window) return EVENT_FAILURE;

    if (!__sync_bool_compare_and_swap(window->id_ptr, &window->id, &window->id)) {
        debug("%s: %d has been marked invalid by the system, ignoring event..\n", __FUNCTION__, window_id);
        window_manager_remove_lost_focused_event(&g_window_manager, window_id);
        return EVENT_FAILURE;
    }

    window->is_minimized = false;
    border_window_show(window);

    if (window_manager_find_lost_focused_event(&g_window_manager, window->id)) {
        struct event *event = event_create(&g_event_loop, WINDOW_FOCUSED, (void *)(intptr_t) window->id);
        event_loop_post(&g_event_loop, event);
        window_manager_remove_lost_focused_event(&g_window_manager, window->id);
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_SPACE_CHANGED)
{
    debug("%s\n", __FUNCTION__);

    if (window_manager_refresh_application_windows(&g_window_manager)) {
        struct window *focused_window = window_manager_focused_window(&g_window_manager);
        if (focused_window && window_manager_find_lost_focused_event(&g_window_manager, focused_window->id)) {
            border_window_activate(focused_window);
            window_manager_remove_lost_focused_event(&g_window_manager, focused_window->id);
        }
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_DISPLAY_CHANGED)
{
    debug("%s\n", __FUNCTION__);

    if (window_manager_refresh_application_windows(&g_window_manager)) {
        struct window *focused_window = window_manager_focused_window(&g_window_manager);
        if (focused_window && window_manager_find_lost_focused_event(&g_window_manager, focused_window->id)) {
            border_window_activate(focused_window);
            window_manager_remove_lost_focused_event(&g_window_manager, focused_window->id);
        }
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_ENTER)
{
    debug("%s:\n", __FUNCTION__);
    g_mission_control_active = true;

    for (int window_index = 0; window_index < g_window_manager.window.capacity; ++window_index) {
        struct bucket *bucket = g_window_manager.window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                border_window_hide(window);
            }

            bucket = bucket->next;
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        struct event *event = event_create(&g_event_loop, MISSION_CONTROL_CHECK_FOR_EXIT, NULL);
        event_loop_post(&g_event_loop, event);
    });

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_CHECK_FOR_EXIT)
{
    if (!g_mission_control_active) return EVENT_FAILURE;

    CFArrayRef window_list = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, 0);
    int window_count = CFArrayGetCount(window_list);
    bool found = false;

    for (int i = 0; i < window_count; ++i) {
        CFDictionaryRef dictionary = CFArrayGetValueAtIndex(window_list, i);

        CFStringRef name = CFDictionaryGetValue(dictionary, kCGWindowName);
        if (name) continue;

        CFStringRef owner = CFDictionaryGetValue(dictionary, kCGWindowOwnerName);
        if (!owner) continue;

        CFNumberRef layer_ref = CFDictionaryGetValue(dictionary, kCGWindowLayer);
        if (!layer_ref) continue;

        uint64_t layer = 0;
        CFNumberGetValue(layer_ref, CFNumberGetType(layer_ref), &layer);
        if (layer != 18) continue;

        if (CFEqual(CFSTR("Dock"), owner)) {
            found = true;
            break;
        }
    }

    if (found) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            struct event *event = event_create(&g_event_loop, MISSION_CONTROL_CHECK_FOR_EXIT, NULL);
            event_loop_post(&g_event_loop, event);
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0f), dispatch_get_main_queue(), ^{
            struct event *event = event_create(&g_event_loop, MISSION_CONTROL_EXIT, NULL);
            event_loop_post(&g_event_loop, event);
        });
    }

    CFRelease(window_list);
    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_EXIT)
{
    debug("%s:\n", __FUNCTION__);
    g_mission_control_active = false;

    for (int window_index = 0; window_index < g_window_manager.window.capacity; ++window_index) {
        struct bucket *bucket = g_window_manager.window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                if ((!window->application->is_hidden) &&
                    (!window->is_fullscreen) &&
                    (!window->is_minimized) &&
                    (!window_is_fullscreen(window))) {
                    border_window_show(window);
                }
            }

            bucket = bucket->next;
        }
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_SYSTEM_WOKE)
{
    debug("%s:\n", __FUNCTION__);

    struct window *focused_window = window_manager_find_window(&g_window_manager, g_window_manager.focused_window_id);
    if (focused_window) {
        border_window_activate(focused_window);
    }

    return EVENT_SUCCESS;
}

static EVENT_CALLBACK(EVENT_HANDLER_DAEMON_MESSAGE)
{
    FILE *rsp = fdopen(param1, "w");
    if (!rsp) goto out;

    debug_message(__FUNCTION__, context);
    handle_message(rsp, context);
    fflush(rsp);
    fclose(rsp);

out:
    socket_close(param1);
    free(context);

    return EVENT_SUCCESS;
}
