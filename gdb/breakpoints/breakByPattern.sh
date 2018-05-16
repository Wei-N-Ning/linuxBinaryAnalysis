#!/usr/bin/env bash

function buildSUT() {
    echo "
void there() {}
void thereis() {}
void thereisa() {}
void thereisacow() {}
void main() {
    there(); thereis(); thereisa(); thereisacow();
}
" > /tmp/_.c
    gcc -g -o /tmp/_ /tmp/_.c
}

function runGDB() {
    gdb --batch \
-ex "rbreak there*" \
-ex "i break" /tmp/_
}

buildSUT
runGDB
