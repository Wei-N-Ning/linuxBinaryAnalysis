#!/usr/bin/env bash

# encourage the use of -Wall -Werror -Wpedantic

function demo() {
    echo "
main() {
}
" > /tmp/_.c
    local flags=
    local ioflags="-o /tmp/_ /tmp/_.c"

    ( gcc ${flags} ${ioflags} 2>/dev/null ) && echo "pass"

    local flags="-Wall -Werror -Wpedantic"
    ! ( gcc ${flags} ${ioflags} 2>/dev/null ) && echo "should fail"
}

demo
