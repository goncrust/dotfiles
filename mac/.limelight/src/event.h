#ifndef EVENT_LOOP_EVENT_H
#define EVENT_LOOP_EVENT_H

#define EVENT_CALLBACK(name) uint32_t name(void *context, int param1)
typedef EVENT_CALLBACK(event_callback);

static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_LAUNCHED);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_TERMINATED);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_FRONT_SWITCHED);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_ACTIVATED);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_DEACTIVATED);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_VISIBLE);
static EVENT_CALLBACK(EVENT_HANDLER_APPLICATION_HIDDEN);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_CREATED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_DESTROYED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_FOCUSED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_MOVED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_RESIZED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_MINIMIZED);
static EVENT_CALLBACK(EVENT_HANDLER_WINDOW_DEMINIMIZED);
static EVENT_CALLBACK(EVENT_HANDLER_SPACE_CHANGED);
static EVENT_CALLBACK(EVENT_HANDLER_DISPLAY_CHANGED);
static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_ENTER);
static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_CHECK_FOR_EXIT);
static EVENT_CALLBACK(EVENT_HANDLER_MISSION_CONTROL_EXIT);
static EVENT_CALLBACK(EVENT_HANDLER_SYSTEM_WOKE);
static EVENT_CALLBACK(EVENT_HANDLER_DAEMON_MESSAGE);

#define EVENT_QUEUED    0x0
#define EVENT_PROCESSED 0x1

#define EVENT_SUCCESS 0x0
#define EVENT_FAILURE 0x1

#define event_status(e) ((e)  & 0x1)
#define event_result(e) ((e) >> 0x1)

enum event_type
{
    EVENT_TYPE_UNKNOWN,

    APPLICATION_LAUNCHED,
    APPLICATION_TERMINATED,
    APPLICATION_FRONT_SWITCHED,
    APPLICATION_ACTIVATED,
    APPLICATION_DEACTIVATED,
    APPLICATION_VISIBLE,
    APPLICATION_HIDDEN,
    WINDOW_CREATED,
    WINDOW_DESTROYED,
    WINDOW_FOCUSED,
    WINDOW_MOVED,
    WINDOW_RESIZED,
    WINDOW_MINIMIZED,
    WINDOW_DEMINIMIZED,
    SPACE_CHANGED,
    DISPLAY_CHANGED,
    MISSION_CONTROL_ENTER,
    MISSION_CONTROL_CHECK_FOR_EXIT,
    MISSION_CONTROL_EXIT,
    SYSTEM_WOKE,
    DAEMON_MESSAGE,

    EVENT_TYPE_COUNT
};

static const char *event_type_str[] =
{
    [EVENT_TYPE_UNKNOWN]             = "event_type_unknown",

    [APPLICATION_LAUNCHED]           = "application_launched",
    [APPLICATION_TERMINATED]         = "application_terminated",
    [APPLICATION_FRONT_SWITCHED]     = "application_front_switched",
    [APPLICATION_ACTIVATED]          = "application_activated",
    [APPLICATION_DEACTIVATED]        = "application_deactivated",
    [APPLICATION_VISIBLE]            = "application_visible",
    [APPLICATION_HIDDEN]             = "application_hidden",
    [WINDOW_CREATED]                 = "window_created",
    [WINDOW_DESTROYED]               = "window_destroyed",
    [WINDOW_FOCUSED]                 = "window_focused",
    [WINDOW_MOVED]                   = "window_moved",
    [WINDOW_RESIZED]                 = "window_resized",
    [WINDOW_MINIMIZED]               = "window_minimized",
    [WINDOW_DEMINIMIZED]             = "window_deminimized",
    [SPACE_CHANGED]                  = "space_changed",
    [DISPLAY_CHANGED]                = "display_changed",
    [MISSION_CONTROL_ENTER]          = "mission_control_enter",
    [MISSION_CONTROL_CHECK_FOR_EXIT] = "mission_control_check_for_exit",
    [MISSION_CONTROL_EXIT]           = "mission_control_exit",
    [SYSTEM_WOKE]                    = "system_woke",
    [DAEMON_MESSAGE]                 = "daemon_message",

    [EVENT_TYPE_COUNT]               = "event_type_count"
};

static event_callback *event_handler[] =
{
    [APPLICATION_LAUNCHED]           = EVENT_HANDLER_APPLICATION_LAUNCHED,
    [APPLICATION_TERMINATED]         = EVENT_HANDLER_APPLICATION_TERMINATED,
    [APPLICATION_FRONT_SWITCHED]     = EVENT_HANDLER_APPLICATION_FRONT_SWITCHED,
    [APPLICATION_ACTIVATED]          = EVENT_HANDLER_APPLICATION_ACTIVATED,
    [APPLICATION_DEACTIVATED]        = EVENT_HANDLER_APPLICATION_DEACTIVATED,
    [APPLICATION_VISIBLE]            = EVENT_HANDLER_APPLICATION_VISIBLE,
    [APPLICATION_HIDDEN]             = EVENT_HANDLER_APPLICATION_HIDDEN,
    [WINDOW_CREATED]                 = EVENT_HANDLER_WINDOW_CREATED,
    [WINDOW_DESTROYED]               = EVENT_HANDLER_WINDOW_DESTROYED,
    [WINDOW_FOCUSED]                 = EVENT_HANDLER_WINDOW_FOCUSED,
    [WINDOW_MOVED]                   = EVENT_HANDLER_WINDOW_MOVED,
    [WINDOW_RESIZED]                 = EVENT_HANDLER_WINDOW_RESIZED,
    [WINDOW_MINIMIZED]               = EVENT_HANDLER_WINDOW_MINIMIZED,
    [WINDOW_DEMINIMIZED]             = EVENT_HANDLER_WINDOW_DEMINIMIZED,
    [SPACE_CHANGED]                  = EVENT_HANDLER_SPACE_CHANGED,
    [DISPLAY_CHANGED]                = EVENT_HANDLER_DISPLAY_CHANGED,
    [MISSION_CONTROL_ENTER]          = EVENT_HANDLER_MISSION_CONTROL_ENTER,
    [MISSION_CONTROL_CHECK_FOR_EXIT] = EVENT_HANDLER_MISSION_CONTROL_CHECK_FOR_EXIT,
    [MISSION_CONTROL_EXIT]           = EVENT_HANDLER_MISSION_CONTROL_EXIT,
    [SYSTEM_WOKE]                    = EVENT_HANDLER_SYSTEM_WOKE,
    [DAEMON_MESSAGE]                 = EVENT_HANDLER_DAEMON_MESSAGE,
};

struct event
{
    void *context;
    volatile uint32_t *info;
    enum event_type type;
    int param1;
};

struct event *event_create(struct event_loop *event_loop, enum event_type type, void *context);
struct event *event_create_p1(struct event_loop *event_loop, enum event_type type, void *context, int param1);
void event_destroy(struct event_loop *event_loop, struct event *event);

#endif
