
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include <sys/ptrace.h>

int isDebuggerPresentPTrace() {
    if (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1) {
        return 1;
    }
    return 0;
}

int isDebuggerPresentProcStatus() {
    char buf[1024];
    const char *key = "TracerPid:\t";
    const int keyLen = strlen(key);
    char *found = 0x0;
    FILE *fp = fopen("/proc/self/status", "r");
    fread(buf, 1024, 1, fp);
    fclose(fp);
    found = strstr(buf, key);
    if (found && *(found + keyLen) != '0') {
        return 1;
    }
    return 0;
}

void once() {
    assert(0 == isDebuggerPresentProcStatus());
    assert(0 == isDebuggerPresentPTrace());
}

void timed(int(*f)(void), int times, const char* title) {
    time_t start = clock();
    for (int i = 0; i < times; ++i) {
        f();
    }
    double us = clock() - start;
    printf("%s (executed %d times): %f us (%f s)\n", title, times, (float)us, (float)(us / 1e6));
}

int main() {
    once();
    timed(isDebuggerPresentPTrace, 1000, "isDebuggerPresentPTrace");
    timed(isDebuggerPresentProcStatus, 1000, "isDebuggerPresentProcStatus");
    return 0;
}

