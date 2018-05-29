#!/usr/bin/env bash

# read:
# https://stackoverflow.com/questions/26943102/how-to-set-runpath-of-a-binary
# http://blog.tremily.us/posts/rpath/
#
# the form is
# -Wl,-rpath=/a/b/c -Wl,--enable-new-dtags

setUp() {
    set -e
    rm -rf /tmp/vol
    mkdir -p /tmp/vol/libs
    mkdir -p /tmp/vol/apps
    mkdir -p /tmp/vol/opt/libs
}

buildSharedLib() {
    echo "
#ifndef IDDQD
#define IDDQD (-1)
#endif
int generate() {
    return IDDQD;
}
" > /tmp/_.c
    gcc -DIDDQD=1001 -shared -fPIC -o /tmp/vol/libs/libgen.so /tmp/_.c
    gcc -DIDDQD=3303 -shared -fPIC -o /tmp/vol/opt/libs/libgen.so /tmp/_.c
}

# $1: runpath (still use -Wl,-rpath parameter)
buildAPP() {
    echo "
#include <iostream>
extern \"C\" int generate();
int main() {
    std::cout << generate() << std::endl;
    return 0;
}
" > /tmp/_.cpp
    g++ /tmp/_.cpp -o /tmp/vol/apps/app -Wl,-L/tmp/vol/libs -Wl,-rpath=${1} -Wl,--enable-new-dtags -Wl,-lgen
    readelf -d /tmp/vol/apps/app | grep -i runpath
}

runAPP() {
    (cd /tmp/vol/apps && ./app)
}

setUp
buildSharedLib
buildAPP "../libs"

# prefer optimized libraries, which are stored in /tmp/vol/opt/libs
# this is managed by some environment configuration system
LD_LIBRARY_PATH=/tmp/vol/opt/libs runAPP

# if this optimized lib does not exist, fall back to the default
# library in /tmp/vol/libs
runAPP
