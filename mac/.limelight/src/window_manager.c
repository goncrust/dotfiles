#include "window_manager.h"

extern int g_connection;
extern struct process_manager g_process_manager;

static TABLE_HASH_FUNC(hash_wm)
{
    return *(uint32_t *) key;
}

static TABLE_COMPARE_FUNC(compare_wm)
{
    return *(uint32_t *) key_a == *(uint32_t *) key_b;
}

void window_manager_set_border_window_width(struct window_manager *wm, int width)
{
    wm->window_border_width = width;
    for (int window_index = 0; window_index < wm->window.capacity; ++window_index) {
        struct bucket *bucket = wm->window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                if (window->border.id) {
                    window->border.width = width;
                    CGContextSetLineWidth(window->border.context, width);

                    if ((!window->application->is_hidden) &&
                        (!window->is_minimized) &&
                        (!window->is_fullscreen)) {
                        border_window_refresh(window);
                    }
                }
            }

            bucket = bucket->next;
        }
    }
}

void window_manager_set_border_window_radius(struct window_manager *wm, float radius)
{
    wm->window_border_radius = radius;
    for (int window_index = 0; window_index < wm->window.capacity; ++window_index) {
        struct bucket *bucket = wm->window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                if (window->border.id) {
                    window->border.radius = radius;

                    if ((!window->application->is_hidden) &&
                        (!window->is_minimized) &&
                        (!window->is_fullscreen)) {
                        border_window_refresh(window);
                    }
                }
            }

            bucket = bucket->next;
        }
    }
}

void window_manager_set_active_border_window_color(struct window_manager *wm, uint32_t color)
{
    wm->active_window_border_color = color;
    struct window *window = window_manager_focused_window(wm);
    if (window) border_window_activate(window);
}

void window_manager_set_normal_border_window_color(struct window_manager *wm, uint32_t color)
{
    wm->normal_window_border_color = color;
    for (int window_index = 0; window_index < wm->window.capacity; ++window_index) {
        struct bucket *bucket = wm->window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                if (window->id != wm->focused_window_id) {
                    if ((!window->application->is_hidden) &&
                        (!window->is_minimized) &&
                        (!window->is_fullscreen)) {
                        border_window_deactivate(window);
                    }
                }
            }

            bucket = bucket->next;
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
struct application *window_manager_focused_application(struct window_manager *wm)
{
    ProcessSerialNumber psn = {};
    _SLPSGetFrontProcess(&psn);

    pid_t pid;
    GetProcessPID(&psn, &pid);

    return window_manager_find_application(wm, pid);
}

struct window *window_manager_focused_window(struct window_manager *wm)
{
    struct application *application = window_manager_focused_application(wm);
    if (!application) return NULL;

    uint32_t window_id = application_focused_window(application);
    return window_manager_find_window(wm, window_id);
}
#pragma clang diagnostic pop

bool window_manager_find_lost_front_switched_event(struct window_manager *wm, pid_t pid)
{
    return table_find(&wm->application_lost_front_switched_event, &pid) != NULL;
}

void window_manager_remove_lost_front_switched_event(struct window_manager *wm, pid_t pid)
{
    table_remove(&wm->application_lost_front_switched_event, &pid);
}

void window_manager_add_lost_front_switched_event(struct window_manager *wm, pid_t pid)
{
    table_add(&wm->application_lost_front_switched_event, &pid, (void *)(intptr_t) 1);
}

bool window_manager_find_lost_focused_event(struct window_manager *wm, uint32_t window_id)
{
    return table_find(&wm->window_lost_focused_event, &window_id) != NULL;
}

void window_manager_remove_lost_focused_event(struct window_manager *wm, uint32_t window_id)
{
    table_remove(&wm->window_lost_focused_event, &window_id);
}

void window_manager_add_lost_focused_event(struct window_manager *wm, uint32_t window_id)
{
    table_add(&wm->window_lost_focused_event, &window_id, (void *)(intptr_t) 1);
}

struct window *window_manager_find_window(struct window_manager *wm, uint32_t window_id)
{
    return table_find(&wm->window, &window_id);
}

void window_manager_remove_window(struct window_manager *wm, uint32_t window_id)
{
    table_remove(&wm->window, &window_id);
}

void window_manager_add_window(struct window_manager *wm, struct window *window)
{
    table_add(&wm->window, &window->id, window);
}

struct application *window_manager_find_application(struct window_manager *wm, pid_t pid)
{
    return table_find(&wm->application, &pid);
}

void window_manager_remove_application(struct window_manager *wm, pid_t pid)
{
    table_remove(&wm->application, &pid);
}

void window_manager_add_application(struct window_manager *wm, struct application *application)
{
    table_add(&wm->application, &application->pid, application);
}

struct window **window_manager_find_application_windows(struct window_manager *wm, struct application *application, int *count)
{
    int window_count = 0;
    uint32_t window_list[MAXLEN];

    for (int window_index = 0; window_index < wm->window.capacity; ++window_index) {
        struct bucket *bucket = wm->window.buckets[window_index];
        while (bucket) {
            if (bucket->value) {
                struct window *window = bucket->value;
                if (window->application == application) {
                    window_list[window_count++] = window->id;
                }
            }

            bucket = bucket->next;
        }
    }

    if (!window_count) return NULL;

    struct window **result = malloc(sizeof(struct window *) * window_count);
    *count = window_count;

    for (int i = 0; i < window_count; ++i) {
        result[i] = window_manager_find_window(wm, window_list[i]);
    }

    return result;
}

void window_manager_add_application_windows(struct window_manager *wm, struct application *application)
{
    CFArrayRef window_list_ref = application_window_list(application);
    if (!window_list_ref) return;

    int window_count = CFArrayGetCount(window_list_ref);
    for (int i = 0; i < window_count; ++i) {
        AXUIElementRef window_ref = CFArrayGetValueAtIndex(window_list_ref, i);
        uint32_t window_id = ax_window_id(window_ref);
        if (!window_id || window_manager_find_window(wm, window_id)) continue;

        struct window *window = window_create(application, CFRetain(window_ref), window_id);
        if (window_is_popover(window) || window_is_unknown(window)) {
            debug("%s: ignoring window %s %d\n", __FUNCTION__, window->application->name, window->id);
            window_destroy(window);
            continue;
        }

        if (!window_observe(window)) {
            debug("%s: could not observe %s %d\n", __FUNCTION__, window->application->name, window->id);
            window_unobserve(window);
            window_destroy(window);
            continue;
        }

        debug("%s: %s %d\n", __FUNCTION__, window->application->name, window->id);
        window_manager_add_window(wm, window);
    }

    CFRelease(window_list_ref);
}

bool window_manager_refresh_application_windows(struct window_manager *wm)
{
    int window_count = wm->window.count;
    for (int i = 0; i < wm->application.capacity; ++i) {
        struct bucket *bucket = wm->application.buckets[i];
        while (bucket) {
            if (bucket->value) {
                struct application *application = bucket->value;
                window_manager_add_application_windows(wm, application);
            }
            bucket = bucket->next;
        }
    }

    return window_count != wm->window.count;
}

void window_manager_init(struct window_manager *wm)
{
    wm->system_element = AXUIElementCreateSystemWide();
    AXUIElementSetMessagingTimeout(wm->system_element, 1.0);

    wm->window_border_width = 4;
    wm->window_border_radius = -1.0;
    wm->window_border_placement = BORDER_PLACEMENT_INTERIOR;
    wm->active_window_border_color = 0xff775759;
    wm->normal_window_border_color = 0xff555555;

    table_init(&wm->application, 150, hash_wm, compare_wm);
    table_init(&wm->window, 150, hash_wm, compare_wm);
    table_init(&wm->window_lost_focused_event, 150, hash_wm, compare_wm);
    table_init(&wm->application_lost_front_switched_event, 150, hash_wm, compare_wm);
}

void window_manager_begin(struct window_manager *wm)
{
    for (int process_index = 0; process_index < g_process_manager.process.capacity; ++process_index) {
        struct bucket *bucket = g_process_manager.process.buckets[process_index];
        while (bucket) {
            if (bucket->value) {
                struct process *process = bucket->value;
                struct application *application = application_create(process);

                if (application_observe(application)) {
                    window_manager_add_application(wm, application);
                    window_manager_add_application_windows(wm, application);
                } else {
                    application_unobserve(application);
                    application_destroy(application);
                }
            }

            bucket = bucket->next;
        }
    }

    struct window *window = window_manager_focused_window(wm);
    if (window) {
        border_window_activate(window);
        wm->focused_window_id = window->id;
        wm->focused_window_psn = window->application->psn;
    }
}

bool display_manager_display_is_animating(uint32_t did)
{
    CFStringRef uuid = display_uuid(did);
    if (!uuid) return false;

    bool result = SLSManagedDisplayIsAnimating(g_connection, uuid);
    CFRelease(uuid);
    return result;
}

CFStringRef display_uuid(uint32_t did)
{
    CFUUIDRef uuid_ref = CGDisplayCreateUUIDFromDisplayID(did);
    if (!uuid_ref) return NULL;

    CFStringRef uuid_str = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);

    return uuid_str;
}

uint32_t *space_window_list(uint64_t sid, int *count, bool include_minimized)
{
    uint32_t *window_list = NULL;
    uint64_t set_tags = 0;
    uint64_t clear_tags = 0;
    uint32_t options = include_minimized ? 0x7 : 0x2;

    CFArrayRef space_list_ref = cfarray_of_cfnumbers(&sid, sizeof(uint64_t), 1, kCFNumberSInt64Type);
    CFArrayRef window_list_ref = SLSCopyWindowsWithOptionsAndTags(g_connection, 0, space_list_ref, options, &set_tags, &clear_tags);
    if (!window_list_ref) goto err;

    *count = CFArrayGetCount(window_list_ref);
    if (!*count) goto out;

    window_list = malloc(*count * sizeof(uint32_t));

    for (int i = 0; i < *count; ++i) {
        CFNumberRef id_ref = CFArrayGetValueAtIndex(window_list_ref, i);
        CFNumberGetValue(id_ref, CFNumberGetType(id_ref), window_list + i);
    }

out:
    CFRelease(window_list_ref);
err:
    CFRelease(space_list_ref);
    return window_list;
}
