#!/usr/bin/env bash

function buildSUT {
    sut=/tmp/_.c
    out=/tmp/_
    rm -f ${sut} ${out}
    echo '
void _start() {
    __asm__("movl $1, %eax");
    __asm__("xorl %ebx, %ebx");
    __asm__("int $0x80");
}
' > ${sut}
}

function compileGCC() {
    gcc -nostdlib -o ${out} ${sut}
}

function compileCLANG() {
    clang -nostdlib -o ${out} ${sut}
}

function test() {
    if ! ( ${out} )
    then
        echo "crash!"
        exit 1
    fi
}

function run() {
    buildSUT
    compileGCC
    test
    compileCLANG
    test
}

run
