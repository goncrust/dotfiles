#ifndef WINDOW_MANAGER_H
#define WINDOW_MANAGER_H

extern OSStatus _SLPSGetFrontProcess(ProcessSerialNumber *psn);
extern CGError SLSGetWindowOwner(int cid, uint32_t wid, int *wcid);
extern bool SLSManagedDisplayIsAnimating(int cid, CFStringRef uuid);
extern CFUUIDRef CGDisplayCreateUUIDFromDisplayID(uint32_t did);
extern CFArrayRef SLSCopyWindowsWithOptionsAndTags(int cid, uint32_t owner, CFArrayRef spaces, uint32_t options, uint64_t *set_tags, uint64_t *clear_tags);

struct window_manager
{
    AXUIElementRef system_element;
    struct table application;
    struct table window;
    struct table window_lost_focused_event;
    struct table application_lost_front_switched_event;
    uint32_t focused_window_id;
    ProcessSerialNumber focused_window_psn;
    int window_border_width;
    float window_border_radius;
    uint32_t active_window_border_color;
    uint32_t normal_window_border_color;
    enum border_placement window_border_placement;
};

void window_manager_set_border_window_width(struct window_manager *wm, int width);
void window_manager_set_border_window_radius(struct window_manager *wm, float radius);
void window_manager_set_active_border_window_color(struct window_manager *wm, uint32_t color);
void window_manager_set_normal_border_window_color(struct window_manager *wm, uint32_t color);
struct window *window_manager_focused_window(struct window_manager *wm);
struct application *window_manager_focused_application(struct window_manager *wm);
bool window_manager_find_lost_front_switched_event(struct window_manager *wm, pid_t pid);
void window_manager_remove_lost_front_switched_event(struct window_manager *wm, pid_t pid);
void window_manager_add_lost_front_switched_event(struct window_manager *wm, pid_t pid);
bool window_manager_find_lost_focused_event(struct window_manager *wm, uint32_t window_id);
void window_manager_remove_lost_focused_event(struct window_manager *wm, uint32_t window_id);
void window_manager_add_lost_focused_event(struct window_manager *wm, uint32_t window_id);
struct window *window_manager_find_window(struct window_manager *wm, uint32_t window_id);
void window_manager_remove_window(struct window_manager *wm, uint32_t window_id);
void window_manager_add_window(struct window_manager *wm, struct window *window);
struct application *window_manager_find_application(struct window_manager *wm, pid_t pid);
void window_manager_remove_application(struct window_manager *wm, pid_t pid);
void window_manager_add_application(struct window_manager *wm, struct application *application);
struct window **window_manager_find_application_windows(struct window_manager *wm, struct application *application, int *count);
void window_manager_add_application_windows(struct window_manager *wm, struct application *application);
bool window_manager_refresh_application_windows(struct window_manager *wm);
void window_manager_begin(struct window_manager *window_manager);
void window_manager_init(struct window_manager *window_manager);
bool display_manager_display_is_animating(uint32_t did);
uint32_t *space_window_list(uint64_t sid, int *count, bool include_minimized);
CFStringRef display_uuid(uint32_t did);

#endif
