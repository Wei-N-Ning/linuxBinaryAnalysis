#!/usr/bin/env bash

srcPath="../_sut/minimal.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function compile() {
    gcc -o ${binPath} ${srcPath}
}

function readSymbols() {
    readelf -W -s ${binPath}
}

function readDynamicSymbols() {
    readelf -W --dyn-syms ${binPath}
}

compile
readSymbols
readDynamicSymbols
