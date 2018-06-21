#!/usr/bin/env bash

# I wanted something similar to:
# go run $FILE.go
# dotnet run $FILE.cs
# to automate the building and running of a single c program

WHICH=/bin/which
CC=cc
CXX=c++
SUT=/tmp/sut
OUT_FILE=${SUT}/_
FLAGS=
CC_FLAGS=
CXX_FLAGS=

APP=
APP_ARGS=

setUp() {
    ls ${WHICH} >/dev/null 2>&1
    ${WHICH} ${CC} >/dev/null 2>&1
    ${WHICH} ${CXX} >/dev/null 2>&1
    rm -rf ${SUT}
    mkdir -p ${SUT}
}

buildProgram() {
    ${CC} $1 ${FLAGS} -o ${OUT_FILE}
}

runProgram() {
    ${OUT_FILE}
}

tearDown() {
    echo "DONE"
}

parseArgs() {
    if [[ "${1}" != "--" ]]; then
        APP=${1}
        shift 1
    fi
    while [[ ${#} -gt 0 ]]; do
        if [[ "${1}" == "--" ]]; then
            break
        fi
        APP_ARGS="${APP_ARGS} ${1}"
        shift 1
    done
    if [[ ${#} -gt 0 ]]; then
        shift
        FLAGS=${@}
    fi
}

validate() {
    if [[ "${APP}" == "" ]]; then
        echo "missing app name"
        exit 1
    fi
}

run_app() {
    if [[ "${APP}" == "run" ]]; then
        buildProgram ${APP_ARGS}
        runProgram ${APP_ARGS}
        return 0
    else
        echo "unsupported app: ${APP}"
        exit 1
    fi
}

setUp
parseArgs $@
validate
run_app
tearDown

