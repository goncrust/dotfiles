/*
 * Copy me if you can.
 * by 20h
 */

#define _BSD_SOURCE
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/sysinfo.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include <X11/Xlib.h>

char *tzlondon = "Europe/London";

static Display *dpy;

void setstatus(char *str) {
    XStoreName(dpy, DefaultRootWindow(dpy), str);
    XSync(dpy, False);
}

char *smprintf(char *fmt, ...) {
    va_list fmtargs;
    char *ret;
    int len;

    va_start(fmtargs, fmt);
    len = vsnprintf(NULL, 0, fmt, fmtargs);
    va_end(fmtargs);

    ret = malloc(++len);
    if (ret == NULL) {
        perror("malloc");
        exit(1);
    }

    va_start(fmtargs, fmt);
    vsnprintf(ret, len, fmt, fmtargs);
    va_end(fmtargs);

    return ret;
}

void settz(char *tzname) { setenv("TZ", tzname, 1); }

char *mktimes(char *fmt, char *tzname) {
    char buf[129];
    time_t tim;
    struct tm *timtm;

    settz(tzname);
    tim = time(NULL);
    timtm = localtime(&tim);
    if (timtm == NULL)
        return smprintf("");

    if (!strftime(buf, sizeof(buf) - 1, fmt, timtm)) {
        fprintf(stderr, "strftime == 0\n");
        return smprintf("");
    }

    return smprintf("%s", buf);
}

int parse_netdev(unsigned long long int *receivedabs,
                 unsigned long long int *sentabs) {
    char buf[255];
    char *datastart;
    static int bufsize;
    int rval;
    FILE *devfd;
    unsigned long long int receivedacc, sentacc;

    bufsize = 255;
    devfd = fopen("/proc/net/dev", "r");
    rval = 1;

    // Ignore the first three lines of the file
    fgets(buf, bufsize, devfd);
    fgets(buf, bufsize, devfd);

    while (fgets(buf, bufsize, devfd)) {
        if ((datastart = strstr(buf, "lo:")) == NULL) {
            datastart = strstr(buf, ":");

            // With thanks to the conky project at http://conky.sourceforge.net/
            sscanf(
                datastart + 1,
                "%llu  %*d     %*d  %*d  %*d  %*d   %*d        %*d       %llu",
                &receivedacc, &sentacc);
            *receivedabs += receivedacc;
            *sentabs += sentacc;
            rval = 0;
        }
    }

    fclose(devfd);
    return rval;
}

char *get_netusage(unsigned long long int *rec, unsigned long long int *sent) {
    unsigned long long int newrec = 0, newsent = 0;
    int retval;
    double downspeed, upspeed;

    retval = parse_netdev(&newrec, &newsent);
    if (retval) {
        return smprintf("error");
    }

    downspeed = (newrec - *rec) / (1024.0 * 1024.0);
    upspeed = (newsent - *sent) / (1024.0 * 1024.0);

    *rec = newrec;
    *sent = newsent;
    return smprintf("↓ %.2fMB/s ↑ %.2fMB/s", downspeed, upspeed);
}

char *readfile(char *base, char *file) {
    char *path, line[513];
    FILE *fd;

    memset(line, 0, sizeof(line));

    path = smprintf("%s/%s", base, file);
    fd = fopen(path, "r");
    free(path);
    if (fd == NULL)
        return NULL;

    if (fgets(line, sizeof(line) - 1, fd) == NULL)
        return NULL;
    fclose(fd);

    return smprintf("%s", line);
}

char *get_temp(char *base, char *sensor) {
    char *co;

    co = readfile(base, sensor);
    if (co == NULL)
        return smprintf("");
    return smprintf("%02.0f°C", atof(co) / 1000);
}

char *get_memory() {
    int total, free, buffers, cached;
    FILE *f;

    f = fopen("/proc/meminfo", "r");

    if (f == NULL) {
        perror("fopen");
        exit(1);
    }

    fscanf(f,
           "%*s %d %*s"  // mem total
           "%*s %d %*s"  // mem free
           "%*s %*d %*s" // mem available
           "%*s %d %*s"  // buffers
           "%*s %d",     // cached
           &total, &free, &buffers, &cached);
    fclose(f);

    return smprintf("%ldMB/%ldMB", (total - free - buffers - cached) / 1000,
                    total / 1000);
}

struct cpu_usage {
    long int total, used;
};

struct cpu_usage get_cpuload() {
    long int user, nice, system, idle, iowait, irq, softirq;
    struct cpu_usage usage;

    FILE *f;
    f = fopen("/proc/stat", "r");

    if (f == NULL) {
        perror("fopen");
        exit(1);
    }

    fscanf(f, "%*s %ld %ld %ld %ld %ld %ld %ld", &user, &nice, &system, &idle,
           &iowait, &irq, &softirq);

    usage.used = user + nice + system + irq + softirq;
    usage.total = user + nice + system + idle + iowait + irq + softirq;

    fclose(f);

    return usage;
}

char *get_battery(char *base) {
    char *co, status[15];
    int cap;

    co = readfile(base, "present");
    if (co == NULL)
        return smprintf("");
    if (co[0] != '1') {
        free(co);
        return smprintf("not present");
    }
    free(co);

    co = readfile(base, "capacity");
    if (co == NULL) {
        return smprintf("");
    }
    sscanf(co, "%d", &cap);
    free(co);

    co = readfile(base, "status");
    if (!strncmp(co, "Discharging", 11)) {
        strncpy(status, " (Discharging)\0", 15);
    } else if (!strncmp(co, "Charging", 8)) {
        strncpy(status, " (Charging)\0", 12);
    } else if (!strncmp(co, "Full", 4)) {
        strncpy(status, " (Full)\0", 8);
    } else {
        strncpy(status, " (?)\0", 5);
    }
    free(co);

    return smprintf("%d%%%s", cap, status);
}

int main(void) {
    char *status, *cpu, *time, *temp, *network, *memory, *bat;

    struct cpu_usage cpu_i_usage = get_cpuload();
    struct cpu_usage cpu_f_usage;
    double cpu_used, cpu_total;

    unsigned long long rec = 0, sent = 0;

    if (!(dpy = XOpenDisplay(NULL))) {
        fprintf(stderr, "dwmstatus: cannot open display.\n");
        return 1;
    }

    for (;; sleep(2)) {
        cpu_f_usage = get_cpuload();
        cpu_used = cpu_f_usage.used - cpu_i_usage.used;
        cpu_total = cpu_f_usage.total - cpu_i_usage.total;
        cpu = smprintf("%.2f%%", (cpu_used / cpu_total) * 100);

        time = mktimes("%d %b %Y - %H:%M", tzlondon);
        temp = get_temp("/sys/devices/virtual/thermal/thermal_zone0/hwmon1",
                        "temp1_input");
        network = get_netusage(&rec, &sent);
        memory = get_memory();
        bat = get_battery("/sys/class/power_supply/BAT1");

        status = smprintf(" | %s | %s | %s | %s | %s | %s |", network, temp,
                          memory, cpu, bat, time);
        setstatus(status);

        free(temp);
        free(cpu);
        free(time);
        free(status);
        free(memory);
        free(network);
        free(bat);
        cpu_i_usage = cpu_f_usage;
    }

    XCloseDisplay(dpy);

    return 0;
}
