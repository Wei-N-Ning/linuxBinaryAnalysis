#!/usr/bin/env bash

function compile() {
    echo "
void ido() {
    ;
}

int main() {
    ido();
    return 0;
}
" > /tmp/ido.c
    gcc -g -o /tmp/ido /tmp/ido.c
}

function run_gdb() {
    gdb -batch \
-ex "file /tmp/ido" \
-ex "break ido" \
-ex "run" \
-ex "i r"
}

compile
run_gdb

