#!/usr/bin/env bash

# source:
# https://sourceware.org/gdb/onlinedocs/gdb/Set-Watchpoints.html
# case:
# use watch point to investigate a memory violation crash
# it is inspired by an error found in wt's wkou project

# useful instructions:
# d break - will delete all the watchpoints (and breakpoints)
# disable n/ enable n - see http://www.dirac.org/linux/gdb/04-Breakpoints_And_Watchpoints.php



set -e

TEMPDIR=/tmp/sut

tearDown() {
    rm -rf ${TEMPDIR} /tmp/_ /tmp/_.* /tmp/__*
}

setUp() {
    tearDown
    mkdir -p ${TEMPDIR}
}

sutSrc=
sutBin=
buildProgram() {
    sutSrc="$( dirname ${0} )/sut.cpp"
    sutBin="${TEMPDIR}/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++14 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

# note that hardward breakpoint (i.e. watch point) start at number 2
# recall how to set up breakpoint commands in batch mode, see
# breakpoints/command.sh
runProgramWithWatchpoint() {
    echo \
"start
n 2
watch d.m_elements
command 2
print \"@@ m_elements\"
cont
end
c
" > ${TEMPDIR}/command.gdb
    gdb -batch -command=${TEMPDIR}/command.gdb ${sutBin} | perl -lne '/(Old value =)/ && print $1'
}

setUp
buildProgram
runProgramWithWatchpoint
tearDown
