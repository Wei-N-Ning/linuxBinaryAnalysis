#!/usr/bin/env bash

# see:
# https://gcc.gnu.org/ml/gcc-help/2005-12/msg00017.html
# see also (temporarily cd and run executable)
# https://stackoverflow.com/questions/10382141/temporarily-change-current-working-directory-in-bash-to-run-a-command

# note that rpath is an ELF dynamic symbol

setUp() {
    rm -rf /tmp/sut
    mkdir -p /tmp/sut/libs
    set -e
}

buildSharedLib() {
    echo "
int getNumber() {
    return 0xDEAD;
}
" > /tmp/sut/libs/_.c
    gcc -Wall -shared -fPIC -o /tmp/sut/libs/libnum.so /tmp/sut/libs/_.c
}

# $1: rpath
# $2: optional argument
buildSUT() {
    echo "
extern \"C\" int getNumber();
int main() {
    if (getNumber()) {
        return 0;
    }
    return 1;
}
" > /tmp/sut/_.cpp
    g++ -Wall /tmp/sut/_.cpp -o /tmp/sut/app \
    -L/tmp/sut/libs -Wl,-rpath=${1} -lnum ${2}
    readelf -d /tmp/sut/app | grep -i rpath
}

deployLibAndSUTTogether() {
    rm -rf /tmp/deployed
    mkdir -p /tmp/deployed/libs
    cp /tmp/sut/app /tmp/deployed
    cp /tmp/sut/libs/libnum.so /tmp/deployed/libs
}

deployLibAndSUTSeparately() {
    rm -rf /tmp/libs /tmp/deployed
    mkdir /tmp/libs
    mkdir /tmp/deployed
    cp /tmp/sut/app /tmp/deployed
    cp /tmp/sut/libs/libnum.so /tmp/libs
}

runSUT() {
    (cd /tmp/deployed && ./app)
}

setUp
buildSharedLib

buildSUT "./libs"
# app and lib live in SEPARATE directories
# sharing the same deployment root
# /tmp/deployed/app
# /tmp/deployed/libs/libnum.so
deployLibAndSUTTogether
runSUT

buildSUT "../libs"
# app and live live in SEPARATE directories,
# NOT sharing the same deployment root
# rpath holds RELATIVE path
# /tmp/deployed/app
# /tmp/libs/libnum.so
deployLibAndSUTSeparately
runSUT

# source:
# http://longwei.github.io/rpath_origin/
# https://stackoverflow.com/questions/6324131/rpath-origin-not-having-desired-effect
# take advantage of ORIGIN flag to make the relative dependency
# look up path - i.e. rpath - more portable
# note that the rpath argument has to use $ORIGIN
# here is a test case where the app and its bundled lib are
# copied to a different location (/tmp/dup) then executed
buildSUT "\$ORIGIN/../libs" "-Wl,-z,origin"
readelf -d /tmp/sut/app | grep ORIGIN
deployLibAndSUTSeparately
cp -r /tmp/deployed /tmp/dup
/tmp/dup/app
rm -rf /tmp/dup
runSUT

buildSUT "/tmp/libs"
# same scenario as above
# rpath holds ABSOLUTE path
# /tmp/deployed/app
# /tmp/libs/libnum.so
deployLibAndSUTSeparately
runSUT

buildSUT "xxx"
# same scenario, but deliberately write invalid path
# to rpath, expecting at runtime the linker falls back
# to LD_LIBRARY_PATH
deployLibAndSUTSeparately
LD_LIBRARY_PATH=/tmp/libs runSUT
