#!/usr/bin/env bash

# see obj_opt.txt -ggdb3

# this example shows the effect of -ggdb1, -ggdb2 and -ggdb3

setUp() {
    set -e
    rm -rf /tmp/sut /tmp/_ /tmp/_.* /tmp/__*
    mkdir /tmp/sut
}

# $1: cxxflags
# export: sut
sut=
compileCXXSUT() {
    cat > /tmp/sut/main.c <<"EOF"
#include <memory>

#define trajectory(x,n) ( \
    (x) * (n) * 3 + \
    (x) * (n - 1) * 2 + \
    (x) * (n - 2) + \
    (x) )

template<typename T>
void logParam(const T& param) {
    ;
}

template<typename T>
void assertParam(const T& param) {
    ;
}

template<typename T, typename R>
std::shared_ptr<R> factory(const T& param) {
    logParam(param);
    assertParam(param);
    return std::make_shared<R>(param);
}

template<typename T>
class Resource {
public:
    explicit Resource(const T& param) : m_value(param) {}
    const T& get() const { return m_value; }
    T& get() { return m_value; }
private:
    T m_value;
};

int main() {
    auto res = factory<int, Resource<int>>(trajectory(1, 3));
    if (! res->get()) {
        return 1;
    }
    return 0;
}
EOF
    sut=/tmp/sut/main.bin
    g++ -std=c++14 ${1} /tmp/sut/main.c -o ${sut}
}

# the binary contains minimal debug symbols (names and line numbers
# only); note the instantiated function template is not seen via
# "i func" (the return type is void) and gdb does not recognize the
# given macro
gdb1() {
    echo "//////////// gdb info level 1 ////////////"
    cat > /tmp/sut/commands <<"EOF"
start
i func factory
i macro trajectory
EOF
    compileCXXSUT "-g -ggdb1"
    gdb -batch -command=/tmp/sut/commands ${sut} | \
    perl -lne '/\s+factory<|trajectory/ and print'
    stat --printf="%s\n\n" ${sut}
}

# template instantiation information can be retrieved from the debugger,
# however macro definition is still not known
gdb2() {
    echo "//////////// gdb info level 2 ////////////"
    cat > /tmp/sut/commands <<"EOF"
start
i func factory
i macro trajectory
EOF
    compileCXXSUT "-g -ggdb2"
    gdb -batch -command=/tmp/sut/commands ${sut} | \
    perl -lne '/\s+factory<|trajectory/ and print'
    stat --printf="%s\n\n" ${sut}
}

# both function template instantiation and macro definition are
# successfully retrieved from the debugger;
# the size of the binary increases considerably
# 46kb (gdb1) vs 143kb (gdb3)
# the size gets even bigger if there are complex macros
gdb3() {
    echo "//////////// gdb info level 3 ////////////"
    cat > /tmp/sut/commands <<"EOF"
start
i func factory
i macro trajectory
EOF
    compileCXXSUT "-g -ggdb3"
    gdb -batch -command=/tmp/sut/commands ${sut} | \
    perl -lne '/\s+factory<|trajectory/ and print'
    stat --printf="%s\n\n" ${sut}
}

setUp
gdb1
gdb2
gdb3

