#include <ScriptingBridge/ScriptingBridge.h>
#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <dirent.h>
#include <stdbool.h>
#include <assert.h>
#include <fcntl.h>
#include <regex.h>
#include <execinfo.h>
#include <signal.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <semaphore.h>
#include <pthread.h>

#include "misc/macros.h"
#include "misc/notify.h"
#include "misc/log.h"
#include "misc/helpers.h"
#include "misc/memory_pool.h"
#define HASHTABLE_IMPLEMENTATION
#include "misc/hashtable.h"
#undef HASHTABLE_IMPLEMENTATION
#include "misc/socket.h"
#include "misc/socket.c"

#include "event_loop.h"
#include "event.h"
#include "workspace.h"
#include "message.h"
#include "border.h"
#include "window.h"
#include "process_manager.h"
#include "application.h"
#include "window_manager.h"

#include "event_loop.c"
#include "event.c"
#include "workspace.m"
#include "message.c"
#include "border.c"
#include "window.c"
#include "process_manager.c"
#include "application.c"
#include "window_manager.c"

#include "limelight.c"
