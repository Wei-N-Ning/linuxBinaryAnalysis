#!/usr/bin/env bash

# debug symbols can be stored outside the binary

sutSrc="../../_sut/disasmOneFunc.c"
sutOut="/tmp/sut"
symbolFile="/tmp/sut.debug"
testOut="/tmp/out"
tmpScript="/tmp/_.sc"

setUp() {
    set -e
}

# $1: compiler flag passed to gcc
buildSUT() {
    rm -f ${sutOut}
    gcc ${1} -o ${sutOut} ${sutSrc}
}

# read:
# https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html
#
# see also:
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Debugging_with_gdb/separate-debug-files.html
#
# war story
# building production binary and symbols separately
# https://stackoverflow.com/questions/36070648/search-symbols-again-after-setting-debug-file-directory

removeDebugInfo() {
    buildSUT "-g"
    strip -g ${sutOut}

    # Warning message:
    # No symbol table is loaded.
    gdb --batch -ex "list main" ${sutOut}
}

# Note, making debug link is the recommended solution
makeDebugLink() {
    buildSUT "-g"
    objcopy --only-keep-debug ${sutOut} ${testOut}
    strip -g ${sutOut}
    objcopy --add-gnu-debuglink=${testOut} ${sutOut}
    gdb --batch -ex "list main" ${sutOut} >/dev/null
}

setUp
removeDebugInfo
makeDebugLink

