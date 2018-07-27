#!/usr/bin/env bash

# source:
# https://sourceware.org/gdb/talks/esc-west-1999/commands.html

# Like a breakpoint, a tracepoint makes your program stop whenever a
# certain point in the program is reached. However, while a breakpoint
# stops the program for a "long" time (while GDB prompts you and lets
# you type commands), a tracepoint stops the program for only a "short"
# time, after which the program gets to continue with minimal disruption
# of its behavior.

# During this "short" interval, the trace mechanism records the fact that it has been there (ie. that the tracepoint
# was executed), and may also perform certain actions that you've
# requested such as recording the values of selected variables and
# registers. Thus it's not well defined how long a "short" time is,
# but in any event it will be thousands of times shorter than the time
# required for a human to do the same tasks interactively.

# I'm using the same SUT program inspired by some drunk chicken code
# from wt

set -e

TEMPDIR=/tmp/sut

tearDown() {
    rm -rf ${TEMPDIR} /tmp/_ /tmp/_.* /tmp/__*
}

setUp() {
    tearDown
    mkdir -p ${TEMPDIR}
}

sutSrc=
sutBin=
buildProgram() {
    sutSrc="$( dirname ${0} )/sut.cpp"
    sutBin="${TEMPDIR}/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++14 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

setUp
buildProgram
