#!/usr/bin/env bash

# source:
#
# https://blogs.oracle.com/linux/8-gdb-tricks-you-should-know-v2
#
# one of the most basic is to augment points in a program to include
# debug output, without having to recompile and restart the program.

setUp() {
    set -e
}

buildSUT() {
    echo "
#include <string>
#include <list>
using StringList = std::list<std::string>;
int main() {
    StringList sl;
    std::string token{\"13<d\"};
    sl.emplace_back(token);
    sl.emplace_back(token);
    sl.emplace_back(token);
    sl.emplace_back(token);
    return 0;
}
" > /tmp/_.cpp
    g++ -g -std=c++11 -o /tmp/_ /tmp/_.cpp
}

# expect allocator invoked 4 times because the program
# calls emplace_back() 4 times
#
# Note, command itself has to explicitly continue (cont)
# the execution
#
# Note also that list itself delegates resource management
# to its internal allocator - recall John Lakos' talk on
# arena memory
runGDB() {
    echo "
rbreak ::allocate
command 1
print \"@@ called ::allocate()\"
cont
end
run
" > /tmp/_.gdb
    gdb --batch --command=/tmp/_.gdb /tmp/_
}

tearDown() {
    :
}

setUp
buildSUT
runGDB
tearDown

