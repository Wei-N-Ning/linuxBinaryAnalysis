#!/usr/bin/env bash

CC=gcc

setUp() {
    set -e
}

buildProgram() {
    ${CC} -Wall -Werror -o /tmp/_ ./isDebuggerPresentComparison.c
}

runProgram() {
    /tmp/_
}

setUp
buildProgram
runProgram
