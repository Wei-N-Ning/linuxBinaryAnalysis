#!/usr/bin/env bash

# see: your applications vs gdb

function compile() {
    echo "
#include <map>
#include <memory>
#include <string>
#include <vector>
using namespace std;
using DemoType = vector<map<string, int>>;
DemoType factory(int size) {
    DemoType dt(size);
    for (int i=size; i--; ) {
        map<string, int> m{{\"there is a cow\", 32}};
        dt.emplace_back(m);
    }
    return dt;
}
void testPmr() {
    allocator<DemoType> alloc;
    DemoType dt(alloc);
    dt.reserve(10);
}
int main() {
    auto dt = factory(11);
    testPmr();
    return 0;
}
" > /tmp/_.cpp
    g++ -g -std=c++17 -o /tmp/_.o /tmp/_.cpp
}

function testExecutable() {
    if ! ( /tmp/_.o )
    then
        echo "fail to execute"
        exit 1
    fi
}

function doPrint() {
    gdb /tmp/_.o -batch \
-ex "start" \
-ex "frame"
}

compile
testExecutable
doPrint

