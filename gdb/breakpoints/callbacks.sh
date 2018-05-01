#!/usr/bin/env bash

function setUp() {
    sutSrc="$( dirname ${0} )/conditional.cpp"
    sutBin="/tmp/$( basename ${0%.sh} ).o"
    if ! ( g++ -g -std=c++17 -o ${sutBin} ${sutSrc} )
    then
        echo "fail to compile"
        exit 1
    fi
}

function expectCommandsCalled() {
    cat > /tmp/gdbsc.txt <<EOF
break conditional.cpp:27 if spVec->size() > 3
command 1
echo thereisacow\n
i frame
end
r
cont
EOF
    gdb ${sutBin} --batch --command=/tmp/gdbsc.txt
}

setUp
expectCommandsCalled
