#!/usr/bin/env bash

function buildSUTProgram() {
    sutDir="/tmp/elfmeml"
    rm -rf ${sutDir}; mkdir ${sutDir}
    sutExe="${sutDir}/sut"
    sutSrc="suts/sut.c"
    if ! (gcc -o ${sutExe} ${sutSrc} )
    then
        echo "fail to build sut"
        exit 1
    fi
}

# $1: pid
function inspectProcMap() {
    local pid_=${1}
    cat /proc/${pid_}/maps
}

# $1: pid
# [anon]: anonymous memory
# memory with no file system location or path name.
# It includes the working data of a process address space, called the heap
function call_pmap() {
    local pid_=${1}
    pmap -x ${pid_}
}

function executeSUTProgram() {
    poisonPill="/tmp/poisonpill"
    rm -f ${poisonPill}
    ${sutExe} &
    local pid_=$!
    inspectProcMap ${pid_}
    call_pmap ${pid_}
    sleep 1
    touch ${poisonPill}
    wait
}

buildSUTProgram
executeSUTProgram
