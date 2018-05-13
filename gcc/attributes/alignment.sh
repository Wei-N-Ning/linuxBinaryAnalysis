#!/usr/bin/env bash

# source:
# https://gcc.gnu.org/onlinedocs/gcc-3.2/gcc/Variable-Attributes.html

# observe the memory layout when the static variables are aligned in 1,2,4,8,16 bytes
# aligned in 16 bytes:
#0x601030 <one>:	0x000000de	0x00000000	0x00000000	0x00000000
#0x601040 <two>:	0x000000ad	0x00000000	0x00000000	0x00000000
#0x601050 <three>:	0x000000be	0x00000000	0x00000000	0x00000000
#0x601060 <four>:	0x000000ef	0x00000000	0x00000000	0x00000000

function buildProgram() {
    echo "
__attribute__ ((aligned (16))) unsigned char one = 0xDE;
__attribute__ ((aligned (16))) unsigned char two = 0xAD;
__attribute__ ((aligned (16))) unsigned char three = 0xBE;
__attribute__ ((aligned (16))) unsigned char four = 0xEF;
int main(void) {
    return 0;
}
" > /tmp/_.c
    if ! ( gcc -g -o /tmp/_ /tmp/_.c )
    then
        echo "fail to build sut"
        exit 1
    fi
}

function testdrive() {
    if ! ( /tmp/_ )
    then
        echo "crash!"
        exit 1
    fi
}

function runGDB() {
    echo "
start
x/16x &one
cont
" > /tmp/_.gdb
    gdb --batch --command=/tmp/_.gdb /tmp/_
}

buildProgram
testdrive
runGDB