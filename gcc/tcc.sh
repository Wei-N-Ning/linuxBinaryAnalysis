#!/usr/bin/env bash

# I wanted something similar to:
# go run $FILE.go
# dotnet run $FILE.cs
# to automate the building and running of a single c program

CC=
SUT=

setUp() {
    set -e
    ls /bin/which >/dev/null 2>&1
    which cc >/dev/null 2>&1
    CC=cc
    SUT=/tmp/sut
    rm -rf ${SUT}
    mkdir -p ${SUT}
}

# $1: source file
buildProgram() {
    ${CC} $1 -o ${SUT}/_
}

runProgram() {
    ${SUT}/_
}

tearDown() {
    rm -rf ${SUT}
    echo "DONE"
}

setUp
buildProgram $1
runProgram
tearDown

