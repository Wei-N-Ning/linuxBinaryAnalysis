#!/usr/bin/env bash

# source:
# https://stackoverflow.com/questions/4037308/can-i-use-gdb-to-skip-a-line-without-having-to-type-line-numbers
# http://man7.org/linux/man-pages/man3/system.3.html

# this technique is quite useful in the cases
# where I want to bypass some if-statements
# (to reproduce a bug or to test a fixture)
# or other conditional branches

setUp() {
    set -e
    rm -rf /tmp/sut
    mkdir /tmp/sut
}

# sut is deemed to fail (to emulate a buggy code);
# but with jump and temporary breakpoint I can
# bypass the conditional branch and go to the
# desired code path

buildSUT() {
    echo '#include <stdlib.h>
static int a = 100;
int condition(int input) {
    if (input > 0) {
        return 1;
    }
    return 0;
}
int compute() {
    return -a;
}
int main() {
    int factor = compute();
    if (! condition(factor)) {
        return 1;
    }
    system("dd if=/dev/zero of=/tmp/sut/geo bs=1M count=1");
    return 0;
}' > /tmp/sut/_.c
   gcc -Wall -Werror -g /tmp/sut/_.c -o /tmp/sut/_
}

debugSUT() {
    echo '
start
tbreak _.c:17
jump _.c:17
cont
' > /tmp/sut/_.gdb
    gdb -batch -command=/tmp/sut/_.gdb /tmp/sut/_
    ls /tmp/sut/geo
}

setUp
buildSUT
debugSUT
