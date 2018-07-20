#!/usr/bin/env bash

# source
# stackoverflow: dump include paths from gcc

showDefaultIncludePaths_gcc() {
    g++ -E -x c++ - -v </dev/null 2>&1 | \
        perl -lne 'print if /\#include/../End of/'
}

showDefaultIncludePaths_clang() {
    # same arguments work for clang++
    :
}

showDefaultIncludePaths_gcc
showDefaultIncludePaths_clang

