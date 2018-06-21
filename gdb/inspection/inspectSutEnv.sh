#!/usr/bin/env bash

# to inspect SUT's environment (not GDB's; the latter is almost always 
# useless)

CC=cc

setUp() {
    set -e
    rm -rf /tmp/sut
    mkdir -p /tmp/sut
}

buildProgram() {
    cat > /tmp/sut/_.c <<EOF
#include <stdlib.h>
void to_stop() {
    int a = 1;
    if (a) {
        a -= 1;
    } else {
        a += 1;
    }
}
int main() {
    setenv("DFLAG", "thereisafatcowthatthinksitcan1337", 1);
    to_stop();
    return 0;
}
EOF
    ${CC} /tmp/sut/_.c -o /tmp/sut/_
}

runProgram() {
    cat > /tmp/sut/_.gdb <<EOF
b to_stop
r
call printf("%s\n", getenv("DFLAG"))
c
EOF
    gdb -batch \
-command=/tmp/sut/_.gdb \
/tmp/sut/_
}

setUp
buildProgram
runProgram

