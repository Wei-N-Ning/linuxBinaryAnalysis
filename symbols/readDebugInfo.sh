#!/usr/bin/env bash

srcPath="../_sut/minimal.c"
binPath="/tmp/$( basename ${srcPath} ).o"

function assertZero() { if [ "${1}" != "0" ]; then echo "failed"; exit 1; fi }

function assertNotZero() { if [ "${1}" == "0" ]; then echo "failed"; exit 1; fi }

function buildSUT() {
    gcc -o ${binPath} ${1} ${srcPath}
}

function verify_objdump() {
    objdump --debugging ${binPath} 2>/dev/null | wc -l
}

function verify_readelf() {
    readelf -p .debug_info ${binPath} 2>/dev/null | wc -l
}

function demo_withDebugInfo() {
    buildSUT "-g"
    verify_objdump
    assertNotZero $( verify_readelf )
}

function demo_withoutDebugInfo() {
    buildSUT
    verify_objdump
    assertZero $( verify_readelf )
}

demo_withDebugInfo
demo_withoutDebugInfo
