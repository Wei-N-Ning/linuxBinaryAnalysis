#!/usr/bin/env bash

# source:
# https://stackoverflow.com/questions/33728510/how-to-generate-dependency-file-for-executable-during-linking-with-gcc
# https://stackoverflow.com/questions/14735387/linker-option-to-list-libraries-used/14735544#14735544

# ld --trace:
# --trace
#Print the names of the input files as ld processes them.

function buildSrc() {
    echo "void main() {}
" > /tmp/_.c
}

function build() {
    gcc -Wl,--trace -o /tmp/_ /tmp/_.c -lm | awk '
/\.so/ { print }
'
}

function printOnly() {
    # existing lib
    gcc -print-file-name=libm.so
    # nonexisting lib
    gcc -print-file-name=libboost.x

    gcc -print-file-name=libboost_filesystem.so
}

buildSrc
build
echo '---------'
printOnly
