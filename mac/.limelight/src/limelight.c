#define SOCKET_PATH_FMT         "/tmp/limelight_%s.socket"
#define LCFILE_PATH_FMT         "/tmp/limelight_%s.lock"

#define CLIENT_OPT_LONG         "--message"
#define CLIENT_OPT_SHRT         "-m"

#define DEBUG_VERBOSE_OPT_LONG  "--verbose"
#define DEBUG_VERBOSE_OPT_SHRT  "-V"
#define VERSION_OPT_LONG        "--version"
#define VERSION_OPT_SHRT        "-v"
#define CONFIG_OPT_LONG         "--config"
#define CONFIG_OPT_SHRT         "-c"

#define MAJOR 0
#define MINOR 0
#define PATCH 1

#define CONNECTION_CALLBACK(name) void name(uint32_t type, void *data, size_t data_length, void *context, int cid)
typedef CONNECTION_CALLBACK(connection_callback);
extern CGError SLSRegisterConnectionNotifyProc(int cid, connection_callback *handler, uint32_t event, void *context);

struct event_loop g_event_loop;
void *g_workspace_context;
struct process_manager g_process_manager;
struct window_manager g_window_manager;
struct daemon g_daemon;
int g_connection;

bool g_mission_control_active;
char g_socket_file[MAXLEN];
char g_config_file[4096];
char g_lock_file[MAXLEN];
bool g_verbose;

static int client_send_message(int argc, char **argv)
{
    if (argc <= 1) {
        error("limelight-msg: no arguments given! abort..\n");
    }

    char *user = getenv("USER");
    if (!user) {
        error("limelight-msg: 'env USER' not set! abort..\n");
    }

    int sockfd;
    char socket_file[MAXLEN];
    snprintf(socket_file, sizeof(socket_file), SOCKET_PATH_FMT, user);

    if (!socket_connect_un(&sockfd, socket_file)) {
        error("limelight-msg: failed to connect to socket..\n");
    }

    int message_length = argc;
    int argl[argc];

    for (int i = 1; i < argc; ++i) {
        argl[i] = strlen(argv[i]);
        message_length += argl[i];
    }

    char message[message_length];
    char *temp = message;

    for (int i = 1; i < argc; ++i) {
        memcpy(temp, argv[i], argl[i]);
        temp += argl[i];
        *temp++ = '\0';
    }
    *temp++ = '\0';

    if (!socket_write_bytes(sockfd, message, message_length)) {
        error("limelight-msg: failed to send data..\n");
    }

    shutdown(sockfd, SHUT_WR);

    int result = EXIT_SUCCESS;
    int byte_count = 0;
    char rsp[BUFSIZ];

    struct pollfd fds[] = {
        { sockfd, POLLIN, 0 }
    };

    while (poll(fds, 1, -1) > 0) {
        if (fds[0].revents & POLLIN) {
            if ((byte_count = recv(sockfd, rsp, sizeof(rsp)-1, 0)) <= 0) {
                break;
            }

            rsp[byte_count] = '\0';

            if (rsp[0] == FAILURE_MESSAGE[0]) {
                result = EXIT_FAILURE;
                fprintf(stderr, "%s", rsp + 1);
                fflush(stderr);
            } else {
                fprintf(stdout, "%s", rsp);
                fflush(stdout);
            }
        }
    }

    socket_close(sockfd);
    return result;
}

static void acquire_lockfile(void)
{
    int handle = open(g_lock_file, O_CREAT | O_WRONLY, 0600);
    if (handle == -1) {
        error("limelight: could not create lock-file! abort..\n");
    }

    struct flock lockfd = {
        .l_start  = 0,
        .l_len    = 0,
        .l_pid    = getpid(),
        .l_type   = F_WRLCK,
        .l_whence = SEEK_SET
    };

    if (fcntl(handle, F_SETLK, &lockfd) == -1) {
        error("limelight: could not acquire lock-file! abort..\n");
    }
}

static bool get_config_file(char *restrict filename, char *restrict buffer, int buffer_size)
{
    char *xdg_home = getenv("XDG_CONFIG_HOME");
    if (xdg_home && *xdg_home) {
        snprintf(buffer, buffer_size, "%s/limelight/%s", xdg_home, filename);
        if (file_exists(buffer)) return true;
    }

    char *home = getenv("HOME");
    if (!home) return false;

    snprintf(buffer, buffer_size, "%s/.config/limelight/%s", home, filename);
    if (file_exists(buffer)) return true;

    snprintf(buffer, buffer_size, "%s/.%s", home, filename);
    return file_exists(buffer);
}

static void exec_config_file(void)
{
    if (!*g_config_file && !get_config_file("limelightrc", g_config_file, sizeof(g_config_file))) {
        notify("configuration", "could not locate config file..");
        return;
    }

    if (!file_exists(g_config_file)) {
        notify("configuration", "file '%s' does not exist..", g_config_file);
        return;
    }

    if (!ensure_executable_permission(g_config_file)) {
        notify("configuration", "could not set the executable permission bit for '%s'", g_config_file);
        return;
    }

    if (!fork_exec(g_config_file)) {
        notify("configuration", "failed to execute file '%s'", g_config_file);
        return;
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static inline void init_misc_settings(void)
{
    char *user = getenv("USER");
    if (!user) {
        error("limelight: 'env USER' not set! abort..\n");
    }

    snprintf(g_socket_file, sizeof(g_socket_file), SOCKET_PATH_FMT, user);
    snprintf(g_lock_file, sizeof(g_lock_file), LCFILE_PATH_FMT, user);

    NSApplicationLoad();
    signal(SIGCHLD, SIG_IGN);
    signal(SIGPIPE, SIG_IGN);
    CGSetLocalEventsSuppressionInterval(0.0f);
    CGEnableEventStateCombining(false);
    g_connection = SLSMainConnectionID();
}
#pragma clang diagnostic pop

static CONNECTION_CALLBACK(connection_handler)
{
    struct event *event = event_create(&g_event_loop, MISSION_CONTROL_ENTER, NULL);
    event_loop_post(&g_event_loop, event);
}

static void parse_arguments(int argc, char **argv)
{
    if ((string_equals(argv[1], VERSION_OPT_LONG)) ||
        (string_equals(argv[1], VERSION_OPT_SHRT))) {
        fprintf(stdout, "limelight-v%d.%d.%d\n", MAJOR, MINOR, PATCH);
        exit(EXIT_SUCCESS);
    }

    if ((string_equals(argv[1], CLIENT_OPT_LONG)) ||
        (string_equals(argv[1], CLIENT_OPT_SHRT))) {
        exit(client_send_message(argc-1, argv+1));
    }

    for (int i = 1; i < argc; ++i) {
        char *opt = argv[i];

        if ((string_equals(opt, DEBUG_VERBOSE_OPT_LONG)) ||
            (string_equals(opt, DEBUG_VERBOSE_OPT_SHRT))) {
            g_verbose = true;
        } else if ((string_equals(opt, CONFIG_OPT_LONG)) ||
                   (string_equals(opt, CONFIG_OPT_SHRT))) {
            char *val = i < argc - 1 ? argv[++i] : NULL;
            if (!val) error("limelight: option '%s|%s' requires an argument!\n", CONFIG_OPT_LONG, CONFIG_OPT_SHRT);
            snprintf(g_config_file, sizeof(g_config_file), "%s", val);
        } else {
            error("limelight: '%s' is not a valid option!\n", opt);
        }
    }
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        parse_arguments(argc, argv);
    }

    if (is_root()) {
        error("limelight: running as root is not allowed! abort..\n");
    }

    if (!ax_privilege()) {
        error("limelight: could not access accessibility features! abort..\n");
    }

    init_misc_settings();
    acquire_lockfile();

    if (!event_loop_init(&g_event_loop)) {
        error("limelight: could not initialize event_loop! abort..\n");
    }

    process_manager_init(&g_process_manager);
    workspace_event_handler_init(&g_workspace_context);
    window_manager_init(&g_window_manager);

    event_loop_begin(&g_event_loop);
    window_manager_begin(&g_window_manager);
    process_manager_begin(&g_process_manager);
    workspace_event_handler_begin(&g_workspace_context);
    SLSRegisterConnectionNotifyProc(g_connection, connection_handler, 1204, NULL);

    if (!socket_daemon_begin_un(&g_daemon, g_socket_file, message_handler)) {
        error("limelight: could not initialize daemon! abort..\n");
    }

    exec_config_file();
    CFRunLoopRun();
    return 0;
}
