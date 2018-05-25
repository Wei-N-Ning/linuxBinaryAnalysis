#!/usr/bin/env bash

buildSUT() {
    sut=/tmp/_.c
    out=/tmp/_
    rm -f ${sut} ${out}
    echo '
void _start() {

    // insert code here

    __asm__("movl $1, %eax");
    __asm__("xorl %ebx, %ebx");
    __asm__("int $0x80");
}
' > ${sut}
}

# this is to show that even with -nostdlib
# one can still use pthread and write()
#
# source:
# https://linux.die.net/man/2/write
# https://stackoverflow.com/questions/3866217/how-can-i-make-the-system-call-write-print-to-the-screen
# <Linux Programming Interface> P626 (670)
buildSUTWithPthread() {
    sut=/tmp/_.c
    out=/tmp/_
    rm -f ${sut} ${out}
    echo '
#include <pthread.h>
size_t write(int fd, const void *buf, size_t count);
void* worker(void *arg) {
    return arg;
}
void _start() {
    pthread_t t;
    pthread_create(&t, 0, worker, 0);
    pthread_join(t, 0);
    write(1, "asd\n", 4);

    __asm__("movl $1, %eax");
    __asm__("xorl %ebx, %ebx");
    __asm__("int $0x80");
}
' > ${sut}
}

compileGCC() {
    gcc -nostdlib -o ${out} ${sut} ${1}
}

compileCLANG() {
    clang -nostdlib -o ${out} ${sut} ${1}
}

test() {
    if ! ( ${out} )
    then
        echo "crash!"
        exit 1
    fi
}

run() {
    buildSUT
    compileGCC "-Wall"
    test
    compileCLANG "-Wall"
    test

    buildSUTWithPthread
    compileGCC "-Wall -lpthread"
    test
    compileCLANG "-Wall -lpthread"
    test
}

run
