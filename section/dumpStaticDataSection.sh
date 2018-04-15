#!/usr/bin/env bash

srcPath="../_sut/minimal.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function compile() {
    gcc -o ${binPath} ${srcPath}
}

function dumpDataSection() {
    readelf -p .data ${binPath}
}

function dumpRodataSection() {
    readelf -p .rodata ${binPath}
}

compile
dumpDataSection
dumpRodataSection
