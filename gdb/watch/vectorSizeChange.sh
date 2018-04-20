#!/usr/bin/env bash

# inspired by:
# https://stackoverflow.com/questions/8249048/how-to-watch-the-size-of-a-c-stdvector-in-gdb

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
-ex "start" \
-ex "watch dt._M_impl._M_start" \
-ex "cont" \
-ex "quit"
}

setUp
run

