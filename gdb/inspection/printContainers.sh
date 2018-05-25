#!/usr/bin/env bash

# source:
# https://stackoverflow.com/questions/233328/how-do-i-print-the-full-value-of-a-long-string-in-gdb/253120
# how to print all the elements (and their elements) without truncating

# Note, it uses set -e to quit earlier if it fails to build

setUp() {
    set -e
}

buildSUT() {
    echo "
#include <vector>
#include <string>
using Strings = std::vector<std::string>;
int main() {
    Strings s(10, std::string{\"doom\"});
    s.size();
    return 0;
}
" > /tmp/_.cpp
    g++ -g -std=c++11 -o /tmp/_ /tmp/_.cpp
}

runGDB() {
    echo \
"start
n 2
set print elements 1
print s
set print elements 3
print s
set print elements 0
print s" > /tmp/_.gdb
    gdb --batch /tmp/_ --command=/tmp/_.gdb
}

tearDown() {
    :
}

setUp
buildSUT
runGDB
tearDown
