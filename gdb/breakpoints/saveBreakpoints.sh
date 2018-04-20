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

function run() {
    gdb ${sutBin} -batch \
-ex "b saveBreakpoints.cpp:13" \
-ex "b saveBreakpoints.cpp:19" \
-ex "save breakpoints /tmp/saveBreakpoints.bp"
    
    cat /tmp/saveBreakpoints.bp
    
    gdb ${sutBin} -batch \
-ex "source /tmp/saveBreakpoints.bp"

}

setUp
run
