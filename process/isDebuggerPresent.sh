#!/usr/bin/env bash

setUp() {
    set -e
}

buildProgram() {
    cat > /tmp/_.c <<EOF
#include <stdio.h>
#include <string.h>
int detect() {
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
int main() {
    if (detect()) {
        printf("OMG DEBUGGER!!!!\n");
    } else {
        printf("...\n");
    }
    return 0;
}
EOF
    gcc -Wall -Werror -g -o /tmp/_ /tmp/_.c
}

runProgram() {
    /tmp/_
}

runProgramWithGDB() {
    gdb -batch -ex "run" /tmp/_
}

setUp
buildProgram
runProgram
runProgramWithGDB
