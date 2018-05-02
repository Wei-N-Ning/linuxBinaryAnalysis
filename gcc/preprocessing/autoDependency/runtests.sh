#!/usr/bin/env bash

# see gnu make proj 3rd P31
# both gcc and clang can read the source and write makefile
# dependencies

# the resulting list can be very long, for example:
# in wtkoru:
# wkbase/src/io/common
# g++ -std=c++11 -M iofile.hh

function genDependenciesGCC() {
    gcc -M model.c
}

function genDependenciesCLANG() {
    clang -M model.c
}

genDependenciesGCC
genDependenciesCLANG
