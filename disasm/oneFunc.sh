#!/usr/bin/env bash

srcPath="../_sut/disasmOneFunc.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function cleanUp() {
    if [ -f ${binPath} ]
    then
        rm ${binPath}
    fi
}

function compile() {
    gcc -o ${binPath} ${srcPath}
    if [ ! -f ${binPath} ]
    then
        echo "fail to compile sut"
        exit 1
    fi
}

function disassemble() {
    local func=${1-"main"}
    gdb -batch \
    -ex "set disassembly-flavor intel" \
    -ex "file ${binPath}" \
    -ex "disassemble ${func}"
}

compile
disassemble main
