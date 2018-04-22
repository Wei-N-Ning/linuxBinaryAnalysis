#!/usr/bin/env bash

# https://sourceware.org/gdb/onlinedocs/gdb/Type-Printing-API.html#Type-Printing-API
# https://github.com/vuvova/gdb-tools
# 

function setUp() {
    export PYTHONPATH="${PYTHONPATH}:$( dirname ${0} )"
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
-ex "start" \
-ex "py import typePrinting" \
-ex "next 3" \
-ex "p shellMagzine" \
-ex "cont"
}

setUp
run
