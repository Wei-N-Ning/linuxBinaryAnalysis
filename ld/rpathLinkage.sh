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
    -L/tmp/sut/libs -Wl,-rpath=${1} -lnum
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
# /tmp/deployed/app
# /tmp/deployed/libs/libnum.so
deployLibAndSUTTogether
runSUT

buildSUT "../libs"
# /tmp/deployed/app
#       ../libs/libnum.so
deployLibAndSUTSeparately
runSUT

buildSUT "/tmp/libs"
# /tmp/deployed/app
# /tmp/libs/libnum.so
deployLibAndSUTSeparately
runSUT

buildSUT "xxx"
# /tmp/deployed/app
# LD_LIBRARY_PATH=/tmp/libs
# this is to fallback
deployLibAndSUTSeparately
LD_LIBRARY_PATH=/tmp/libs runSUT
