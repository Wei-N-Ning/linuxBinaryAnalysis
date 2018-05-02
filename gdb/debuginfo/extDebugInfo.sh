#!/usr/bin/env bash

# debug symbols can be stored outside the binary

sutSrc="../../_sut/disasmOneFunc.c"
sutOut="/tmp/sut.o"
testOut="/tmp/out"
tmpScript="/tmp/_.sc"

# $1: compiler flag passed to gcc
function buildSUT() {
    rm -f ${sutOut}
    if ! ( gcc ${1} -o ${sutOut} ${sutSrc} )
    then
        echo "fail to compile sut"
        exit 1
    fi
}

# read:
# https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html
function extractDebugInfo() {
    buildSUT "-g"
    objcopy --only-keep-debug ${sutOut} ${testOut}
    strip -g ${testOut}
    objcopy --add-gnu-debuglink=${testOut} ${sutOut}

    cat > ${tmpScript} <<EOF
break test_nothing
command 1
echo "thereisacow\n"
end
r
cont
EOF
    gdb --batch --command=${tmpScript} ${sutOut}
}

extractDebugInfo

