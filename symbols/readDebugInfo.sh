#!/usr/bin/env bash

srcPath="../_sut/minimal.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function compile() {
    gcc -o ${binPath} -g ${srcPath}
}

function readDebugInfo() {
    objdump --debugging ${binPath}
}

compile
readDebugInfo
