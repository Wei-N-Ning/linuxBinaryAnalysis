#!/usr/bin/env bash

# what is .bss section:
# https://en.wikipedia.org/wiki/.bss
# Peter van der Linden, a C programmer and author, says, "Some people like to remember it as
# 'Better Save Space.' Since the BSS segment only holds variables that don't have any value yet,
# it doesn't actually need to store the image of these variables. The size that BSS will require
# at runtime is recorded in the object file, but BSS (unlike the data segment) doesn't take up any
# actual space in the object file."
# only the length of bss is recorded but not the data

function buildSUT() {
    echo "
static int arr[4] = {1, 2, 3, 4};
static char sentence[16] = {'w', 'h', 'a', 't', '?'};
void main() {
    int tmp;
    char c;
    for (int i = 0; i < 4; ++i) {
        tmp = arr[i];
        c = sentence[i];
    }
}
" > /tmp/_.c
    gcc -o /tmp/_ /tmp/_.c
}

#   [26] .bss              NOBITS           0000000000601050  00001050
#       0000000000000008  0000000000000000  WA       0     0     1
# Section '.bss' has no data to dump.
function readBSSContent() {
    readelf -S /tmp/_ | awk '
/.bss/ {
    print;
    getline;
    print;
}'
    readelf -p .bss /tmp/_
}

buildSUT
readBSSContent
