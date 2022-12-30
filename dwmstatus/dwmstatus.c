/*
 * Copy me if you can.
 * by 20h
 */

#define _BSD_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <strings.h>
#include <sys/time.h>
#include <time.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <X11/Xlib.h>

char *tzlondon = "Europe/London";

static Display *dpy;

char *
smprintf(char *fmt, ...)
{
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

void
settz(char *tzname)
{
	setenv("TZ", tzname, 1);
}

char *
mktimes(char *fmt, char *tzname)
{
	char buf[129];
	time_t tim;
	struct tm *timtm;

	settz(tzname);
	tim = time(NULL);
	timtm = localtime(&tim);
	if (timtm == NULL)
		return smprintf("");

	if (!strftime(buf, sizeof(buf)-1, fmt, timtm)) {
		fprintf(stderr, "strftime == 0\n");
		return smprintf("");
	}

	return smprintf("%s", buf);
}

void
setstatus(char *str)
{
	XStoreName(dpy, DefaultRootWindow(dpy), str);
	XSync(dpy, False);
}


long double cpu_curr[] = {0, 0, 0, 0};
long double cpu_last[] = {0, 0, 0, 0};
char *cpuload(void)
{

    FILE *fp;
    float load;
    long double cpu_last_sum, cpu_curr_sum;
    int i;

    fp = fopen("/proc/stat", "r");

    /* read current values */
    fscanf(fp,"%*s %Lf %Lf %Lf %Lf", &cpu_curr[0], &cpu_curr[1], &cpu_curr[2], &cpu_curr[3]);
    fclose(fp);

    cpu_last_sum = cpu_last[0]+cpu_last[1]+cpu_last[2];
    cpu_curr_sum = cpu_curr[0]+cpu_curr[1]+cpu_curr[2];

    if (cpu_last_sum == 0)
        load = 0;
    else
        load = ((cpu_last_sum) - (cpu_curr_sum))
            / ((cpu_last_sum+cpu_last[3]) - (cpu_curr_sum+cpu_curr[3]));

    /* update last values */
    for (i = 0; i < 4; i++) {
        cpu_last[i] = cpu_curr[i];
    }

    if (load <= 0) {
        return smprintf("0%%");
    }
	return smprintf("%.0f%%", load*100);
}

char *
readfile(char *base, char *file)
{
	char *path, line[513];
	FILE *fd;

	memset(line, 0, sizeof(line));

	path = smprintf("%s/%s", base, file);
	fd = fopen(path, "r");
	free(path);
	if (fd == NULL)
		return NULL;

	if (fgets(line, sizeof(line)-1, fd) == NULL)
		return NULL;
	fclose(fd);

	return smprintf("%s", line);
}

char *
getbattery(char *base)
{
	char *co, status[16];
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
		strncpy(status, " (Not Charging)\0", 16);
	} else if(!strncmp(co, "Charging", 8)) {
		strncpy(status, " (Charging)\0", 12);
	} else {
		strncpy(status, " (?)\0", 5);
	}
    free(co);

	return smprintf("%d%%%s", cap, status);
}

char *
gettemperature(char *base, char *sensor)
{
	char *co;

	co = readfile(base, sensor);
	if (co == NULL)
		return smprintf("");
	return smprintf("%02.0f°C", atof(co) / 1000);
}

int
main(void)
{
	char *status;
	char *avgs;
	char *bat;
	char *thour;
	char *t0;

	if (!(dpy = XOpenDisplay(NULL))) {
		fprintf(stderr, "dwmstatus: cannot open display.\n");
		return 1;
	}

	for (;;sleep(5)) {
		avgs = cpuload();
		bat = getbattery("/sys/class/power_supply/BAT1");
		thour = mktimes("%d %b %Y - %H:%M", tzlondon);
		t0 = gettemperature("/sys/devices/virtual/thermal/thermal_zone0/hwmon1", "temp1_input");

		status = smprintf(" | %s | %s | %s | %s ",
				t0, avgs, bat, thour);
		setstatus(status);

		free(t0);
		free(avgs);
		free(bat);
		free(thour);
		free(status);
	}

	XCloseDisplay(dpy);

	return 0;
}

