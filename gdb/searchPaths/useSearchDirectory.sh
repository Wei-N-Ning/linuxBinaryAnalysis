#!/usr/bin/env bash

function generateSUT() {
    rm -rf /tmp/sut
    mkdir /tmp/sut
    mkdir /tmp/sut/src
    echo "
struct Foo;
struct Foo *createFoo();
void deleteFoo(struct Foo *foo);
" > /tmp/foo.h
    echo "
#include <stdlib.h>
struct Foo {
    int size;
    char name[16];
};
struct Foo *createFoo() {
    struct Foo *foo = malloc(sizeof(struct Foo));
    foo->size = 134;
    for (int i=16; i--; ) {
        foo->name[i] = '\0';
    }
    foo->name[0] = 'D'; 
    return foo;
}
void deleteFoo(struct Foo *foo) {
    free(foo);
}
" > /tmp/foo.c
    echo "
#include \"foo.h\"
int main() {
    struct Foo *foo = createFoo();
    deleteFoo(foo);
    return 0;
}
" > /tmp/main.c
    if ! ( gcc -g -o /tmp/sut.o /tmp/foo.c /tmp/main.c )
    then
        echo "fail to compile"
        exit 1
    fi
    mv /tmp/foo.* /tmp/main.c /tmp/sut/src
}

function do_gdb() {
    gdb -d /tmp/sut/src /tmp/sut.o -batch \
-ex "start" \
-ex "list" \
-ex "cont"
}

generateSUT
do_gdb

