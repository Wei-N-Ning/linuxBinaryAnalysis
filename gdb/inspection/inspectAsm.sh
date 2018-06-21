#!/usr/bin/env bash

setUp() {
    set -e
    rm -rf /tmp/sut
    mkdir -p /tmp/sut
}

buildProgram() {
    cat > /tmp/sut/_.c <<EOF
#include <stdlib.h>
void to_stop(int count) {
    int sum = 0;
    for (int i = 0; i <= count; ++i) {
        sum += i;
    }
}
int main() {
    int count = 13;
    to_stop(count);
    return 0;
}
EOF
    gcc /tmp/sut/_.c -o /tmp/sut/_
}

runProgram() {
    cat > /tmp/sut/_.gdb <<EOF
break to_stop
r
x/40i to_stop-40
c
EOF
    gdb -batch \
-command=/tmp/sut/_.gdb \
/tmp/sut/_
}

setUp
buildProgram
runProgram

