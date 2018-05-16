#!/usr/bin/env bash

# case:
#
# two layers of libs:
# app
#    model
#         core
# only the public subroutines exposed from core should be visible
# in model after linking; 
# app should not see any symbols that are hidden in core

source "commonutils.sh"

function createSourceFiles() {
    echo "
typedef struct __Stack Stack;
void push(Stack *s, int v);
int pop(Stack *s);
" > ${sutdir}/core.h

    echo "#include \"core.h\"
struct __Stack {};
void push(Stack *s, int v) {}
int pop(Stack *s) { return 0; }
" > ${sutdir}/core.c

    echo "
void loglength(const char *text);
" > ${sutdir}/model.h

    echo "#include \"core.h\"
#include <string.h>
static Stack *s;
void loglength(const char *text) {
    push(s, strlen(text));
    pop(s);
}
" > ${sutdir}/model.c

    echo "#include \"model.h\"
int main(int argc, char **argv) {
    loglength(\"thereis\");
    loglength(\"thereisa\");
    return 0;
}
" > ${sutdir}/main.c
}

function buildCore() {
    gcc -Wall -fPIC ${1} -c -I${sutdir} -o ${sutdir}/core.o ${sutdir}/core.c
}

function buildModel() {
    gcc -Wall -fPIC ${1} -c -I${sutdir} -o ${sutdir}/model.o ${sutdir}/model.c
}

function buildMain() {
    gcc -Wall ${1} -c -I${sutdir} -o ${sutdir}/main.o ${sutdir}/main.c
}

function buildAppUsingObjs() {
    rm -f ${sutdir}/out
    gcc -Wall -o ${sutdir}/out ${sutdir}/main.o ${sutdir}/model.o ${sutdir}/core.o
}

function buildSTLib() {
    ar rcs -o ${sutdir}/lib.a ${sutdir}/core.o ${sutdir}/model.o
}

function buildAppUsingSTLib() {
    rm -f ${sutdir}/out
    gcc -Wall -o ${sutdir}/out ${sutdir}/main.o ${sutdir}/lib.a
}

function buildSHLib() {
    gcc -Wall -shared ${1} -o ${sutdir}/libmodel.so ${sutdir}/model.o ${sutdir}/core.o
}

function buildAppUsingSHLib() {
    rm -f ${sutdir}/out
    gcc -Wall -o ${sutdir}/out ${sutdir}/main.o -L${sutdir} -lmodel
}

function verifyBuild() {
    if ! ( LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${sutdir} ${sutdir}/out )
    then
        echo "fail to run target"
        exit 1
    fi
    md5sum ${sutdir}/out
    readelf -s ${sutdir}/out | grep -i push
}

setUp
createSourceFiles
buildCore "-fvisibility=hidden"
buildModel
buildMain

# all the "hidden" symbols will be carried over to the executable
buildAppUsingObjs
verifyBuild

# same as above; also note that the md5sum indicates there is
# no difference between these two binaries - the effect of 
# linking against a static lib is the same as that of packing the 
# obj files together
buildSTLib
buildAppUsingSTLib
verifyBuild

# the hidden symbols are gone in the executable
# recall the stackoverflow posts (see note)
# if the end product is a shared library, this should be the way 
# of building it (in order to not cause grief to the library users)
buildSHLib
buildAppUsingSHLib
verifyBuild


