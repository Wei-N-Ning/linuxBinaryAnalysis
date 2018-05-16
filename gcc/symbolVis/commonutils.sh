#!/usr/bin/env bash

sutdir="/tmp/_sut"
sutbin="/tmp/_sut/out"
sutstlib="/tmp/_sut/lib.a"
sutshlib="/tmp/_sut/lib.so"

function setUp() {
    rm -rf ${sutdir}
    mkdir /tmp/_sut
}

function tearDown() {
    rm -rf ${sutdir}
}
