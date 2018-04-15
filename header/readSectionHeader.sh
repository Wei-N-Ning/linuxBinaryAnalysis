#!/usr/bin/env bash

srcPath="../_sut/minimal.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function compile() {
    gcc -o ${binPath} ${srcPath}
}

function doRead() {
    readelf -S ${binPath}
}

compile
doRead
