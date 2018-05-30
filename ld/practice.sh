#!/usr/bin/env bash

# source:
# wt: richard.png

# the pattern is that, app (top level) target uses RPATH to specify where
# it wants to find libraries since it takes responsibility for how
# the process starts but the library targets uses RUNPATH so that
# they do not force a different choice for where to find dependencies.
# We want those shared libraries to defer to the main executables (or
# settings in wrapper script that launches it), whether it is the app
# target in the same code base or a third-party application

setUp() {
    set -e
    rm -rf /tmp/vol
    mkdir -p /tmp/vol/starapp/libs
    mkdir -p /tmp/vol/users/libs
}

# pattern lib is a shared library provides some kind of pattern
# matching functionality
# it is used by both the app target and the business model library
# target
# there are two versions of this library:
# /tmp/vol/libs/starapp/libs/libpattern: this is the one shipped
# with the application "starapp"
# /tmp/vol/users/libs/libpattern: this is the one purchased by the
# users

# scenario 1:
# if a user purchased starapp, the pattern matching library will
# be the copy shipped with the application;

# scenario 2:
# if a user only purchased the business model library, the pattern
# matching library will be provided by the user

buildPatternLib() {
    echo "
#ifndef TOKEN
#define TOKEN 32
#endif
int match(const char *i_arr, int sz, char *o_arr) {
    int count = 0;
    while (sz--) {
        if (i_arr[sz] == '*') {
            o_arr[sz] = TOKEN;
            count++;
        } else {
            o_arr[sz] = i_arr[sz];
        }
    }
    return count;
}" > /tmp/_.c
    gcc -Wall -Werror -shared -fPIC -DTOKEN=120 /tmp/_.c -o /tmp/vol/starapp/libs/libpattern.so
    gcc -Wall -Werror -shared -fPIC /tmp/_.c -o /tmp/vol/users/libs/libpattern.so
}

buildBusinessModel() {
    echo "
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>
extern int match(const char *i_arr, int sz, char *o_arr);
void printService(const char *str) {
    int sz = (int)strlen(str);
    char *o_arr = malloc(sz + 1);
    memset(o_arr, 0, sz + 1);
    match(str, sz, o_arr);
    printf(\"%s\\n\", o_arr);
    free(o_arr);
}
" > /tmp/_.c
    gcc -Wall -Werror -shared -fPIC \
    /tmp/_.c \
    -o /tmp/vol/starapp/libs/libbusiness.so \
    -Wl,-L/tmp/vol/starapp/libs \
    -Wl,-rpath=. \
    -Wl,--enable-new-dtags \
    -Wl,-lpattern
}

buildStarApp() {
    echo "
extern void printService(const char *str);
int main(int argc, char **argv) {
    if (argc > 1) {
        printService(argv[1]);
        return 0;
    }
    return 2;
}
" > /tmp/_.c
    gcc -Wall -Werror /tmp/_.c -o /tmp/vol/starapp/app \
    -Wl,-L/tmp/vol/starapp/libs \
    -Wl,-rpath=libs \
    -Wl,-lbusiness \
    -Wl,--no-as-needed -lpattern
}

buildUserUtil() {
    echo "
extern void printService(const char *str);
int main(int argc, char **argv) {
    if (argc > 1) {
        printService(argv[1]);
        return 0;
    }
    return 2;
}
" > /tmp/_.c
    gcc -Wall -Werror /tmp/_.c -o /tmp/vol/users/util \
    -Wl,--allow-shlib-undefined \
    -Wl,-L/tmp/vol/starapp/libs \
    -Wl,-rpath=/tmp/vol/starapp/libs \
    -Wl,-rpath=/tmp/vol/users/libs \
    -Wl,-lbusiness \
    -Wl,--enable-new-dtags \
    -Wl,--no-as-needed -lpattern

}

runStarApp() {
    (cd /tmp/vol/starapp && ./app STAR-APP::th**ere*isa**cow1**7)
}

runUserApp() {
    # use runpath (the "fallback") to locate the dependencies
    (cd /tmp/vol/users && ./util i**dd**qd**idkfa)

    # use LD_LIBRARY_PATH (the "config") to locate the dependencies
    (cd /tmp/vol/users && LD_LIBRARY_PATH=/tmp/vol/users/libs ./util i**dd**qd**idkfa)
}

setUp
buildPatternLib
buildBusinessModel
buildStarApp
buildUserUtil

runStarApp
runUserApp
