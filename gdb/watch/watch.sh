#!/usr/bin/env bash

function setUp() {
    sutSrc="$( dirname ${0} )/sut.cpp"
    sutBin="/tmp/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++17 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

setUp
