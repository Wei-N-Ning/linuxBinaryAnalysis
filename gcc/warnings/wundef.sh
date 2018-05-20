#!/usr/bin/env bash

function Wundef() {
    echo "
#if DOOM
#define NAME 123
#else
#define NAME -1
#endif
void main() {
    int a = NAME;
}
" > /tmp/_.c
    ( gcc -DDOOM -Werror -Wundef -o /tmp/_ /tmp/_.c ) && echo "pass"
    ! ( gcc -Werror -Wundef -o /tmp/_ /tmp/_.c 2>/dev/null ) && echo "should fail"
}

Wundef