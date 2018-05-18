#!/usr/bin/env bash

function compileGCC() {
    gcc -DDEBUG -S -o /tmp/_.s model.c
    tail -n 10 /tmp/_.s
}

# clang use its own VM instructions
function compileCLANG() {
    clang -DDEBUG -S -o /tmp/_.s model.c
    tail -n 10 /tmp/_.s
}

compileGCC
compileCLANG
