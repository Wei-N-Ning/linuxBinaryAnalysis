#!/usr/bin/env bash

function setUp() {
    sutSrc="$( dirname ${0} )/sut.cpp"
    sutBin="/tmp/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++17 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

# if the frame does not exist, it prints out:
# #0  0x0000000000000000 in ?? ()
#
# frame 0 (f 0) -- the innermost frame (core of the onion)
# frame N (f N) -- the outermost frame (the skin of the onion)
# 
# note that "break factory" wont work, because c++ function name is 
# mangled. I can use source:lineno instead
function selectAndPrintOneStackFrame() {
    echo '--------'
    gdb ${sutBin} -quiet -batch \
-ex "break testPmr" \
-ex "start" \
-ex "cont" \
-ex "frame 0" \
-ex "frame 1" \
-ex "frame 2" \
-ex "cont"
}

# info frame (i f)
#
# ptype -- print type; for templated variable this can be too verbose
# 
# info symbol $pc (i symbol $pc) -- location of the instruction
# read: program counter register
# A program counter is a register in a computer processor that contains 
#  the address (location) of the instruction being executed at the 
# current time.
# https://whatis.techtarget.com/definition/program-counter
function infoFrame() {
    echo '--------'
    gdb ${sutBin} -quiet -batch \
-ex "break testPmr" \
-ex "start" \
-ex "cont" \
-ex "info frame" \
-ex "ptype dt" \
-ex "i symbol \$pc" \
-ex "cont"
}

setUp
selectAndPrintOneStackFrame
infoFrame
