#!/usr/bin/env bash

buildSUT() {
    cat > /tmp/_.c <<EOF
void main(void) {
    int x = -0x10001234, y = 0x10001234;
    int mask = 0x7FFF;
    x = x >> 16;
    x = x & mask;
    ;
    ;
}
EOF
    if ! ( gcc -g -o /tmp/_ /tmp/_.c )
    then
        echo "fail to build sut"
        exit 1
    fi
}

examineMemHex() {
    cat > /tmp/_.gdb <<EOF
start
n
x/4x &x
x/4x &y
n 2
x/4x &x
n
x/4x &x
cont
EOF
    gdb --batch --command=/tmp/_.gdb /tmp/_
}

examineMemString() {
    echo "
start
n
x/s &x
" > /tmp/_.gdb
    gdb --batch --command=/tmp/_.gdb /tmp/_
}

buildSUT
examineMemHex
examineMemString
