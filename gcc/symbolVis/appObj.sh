#!/usr/bin/env bash

# case:
# 
# there is a "lib" artifact and an executable, the "app"
# app uses a subroutine exposed from the lib 
# the visibility of the symbols in lib and app does not really matter

# to re-emphasize: to plain .o files and static library, symbol
# visibility do not affect the user

source commonutils.sh

function createSUTSourceFiles() {
    echo "int fillarr(int *arr, int sz);" > ${sutdir}/lib.hpp
    echo "#include <vector>
int fillarr(int *arr, int sz) {
    std::vector<int> v(sz);
    for (; sz--; arr[sz] = 0xDEAD) ;
    return sz;
}" > ${sutdir}/lib.cpp
    echo "#include \"${sutdir}/lib.hpp\"
#include <cstdlib>
static int sz = 0xBE;
static int *arr = 0x0;
namespace {
void startProbe() { arr = (int *)malloc(sizeof(int) * sz); fillarr(arr, sz); }
void finalizeProbe() { delete arr; }
class Probe {
public:
    Probe() { startProbe(); }
    ~Probe() { finalizeProbe(); }
};
}
int main() {
    Probe _raii;
    return 0;
}" > ${sutdir}/main.cpp
}

function buildLib() {
    g++ -Wall -c ${1} -o ${sutdir}/lib.o ${sutdir}/lib.cpp
}

function buildApp() {
    g++ -Wall ${1} -o ${sutbin} ${sutdir}/main.cpp ${sutdir}/lib.o
}

function buildAll() {
    if ! ( buildLib ${1} )
    then
        echo "fail to build lib"; exit 1
    fi
    if ! ( buildApp ${2} )
    then
        echo "fail to build app"; exit 1
    fi
}

function verifyBuild() {
    if ! ( ${sutbin} )
    then
        echo "fail to execute target"; exit 1
    fi
    readelf -s /tmp/_sut/out | awk '/fillarr/ { print $5, $6, $8 }'
}

setUp
createSUTSourceFiles
buildAll 
verifyBuild
buildAll "-fvisibility=hidden"
verifyBuild
tearDown

