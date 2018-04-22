#!/usr/bin/env bash

# https://sourceware.org/gdb/onlinedocs/gdb/Basic-Python.html#Basic-Python
# https://sourceware.org/gdb/onlinedocs/gdb/Values-From-Inferior.html#Values-From-Inferior
#
# import module
# inspect existing breakpoints (python objects)
# inspect a primitive value
# inspect a C++ stl container (std::vector)

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
-ex "next 2" \
-ex "py import basics" \
-ex "py basics.main()"
}

setUp
run
