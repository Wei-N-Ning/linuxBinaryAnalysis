#!/usr/bin/env bash

buildSUT() {
    cat > /tmp/_.c <<EOF
#include <stdio.h>
#include <sys/ptrace.h>

int main() {
    if (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1) {
        printf("don't trace me !!\n");
        return 1;
    }
    // normal execution
    return 0;
}
EOF
    gcc -o /tmp/_ /tmp/_.c
}

runSUTInGDB() {
    gdb -batch -ex "run" /tmp/_
}

set -e
buildSUT
runSUTInGDB

