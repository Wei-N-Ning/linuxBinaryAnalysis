#!/usr/bin/env bash

# source:
# https://blogs.oracle.com/linux/8-gdb-tricks-you-should-know-v2

# Note that the condition is evaluated by gdb, not by the debugged program, so you
# still pay the cost of the target stopping and switching to gdb every time the
# breakpoint is hit. As such, they still slow the target down in relation to to
# how often the target location is hit, not how often the condition is met.

function setUp() {
    sutSrc="$( dirname ${0} )/$( basename ${0%.sh} ).cpp"
    sutBin="/tmp/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++17 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

function runExpectHit() {
    gdb ${sutBin} -batch \
-ex "break conditional.cpp:27 if spVec->size() > 3" \
-ex "start" \
-ex "cont" \
-ex "cont"
}

function runExpectMissed {
    gdb ${sutBin} -batch \
-ex "break conditional.cpp:27 if spVec->size() > 30" \
-ex "start" \
-ex "cont"
}

setUp
echo "---------"
runExpectHit
echo "---------"
runExpectMissed
