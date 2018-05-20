#!/usr/bin/env bash

# see gnu make proj 3rd P31
# both gcc and clang can read the source and write makefile
# dependencies

# the resulting list can be very long, for example:
# in wtkoru:
# wkbase/src/io/common
# g++ -std=c++11 -M iofile.hh

# see also:
# https://stackoverflow.com/questions/33728510/how-to-generate-dependency-file-for-executable-during-linking-with-gcc
#
# gcc has -M-class options (-MMD, -MF, etc.) that allows to generate dependency
# file during compiling source file.
# The dependency file contains Makefile rules describing on which source files
# and headers the generated object file
# depends on. The dependency file may be included into Makefile and then make will
# automatically recompile source file
# when headers are changed.

function genDependenciesGCC() {
    gcc -M model.c
}

function genDependenciesCLANG() {
    clang -M model.c
}

genDependenciesGCC
genDependenciesCLANG
