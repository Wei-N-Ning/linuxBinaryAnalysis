#!/usr/bin/env bash

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
