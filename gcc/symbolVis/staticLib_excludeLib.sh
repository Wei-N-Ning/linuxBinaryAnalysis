#!/usr/bin/env bash

# source:
# https://stackoverflow.com/questions/28469428/how-to-hide-apis-of-static-library-included-by-another-one
# https://gcc.gnu.org/ml/gcc-help/2011-08/msg00179.html

setUp() {
    set -e
    rm -rf /tmp/sut /tmp/_ /tmp/_.* /tmp/__*
    mkdir /tmp/sut
}

# $1: global variable unitPrice's type modifier
# $2: additional CFLAGS
buildStaticLib() {
    mkdir -p /tmp/sut/lib
    cat > /tmp/sut/lib/fuel.c <<EOF
${1} int unitPrice = 23;
int calcPrice(int liters) {
    return unitPrice * liters;
}
EOF
    gcc -c ${2} -o /tmp/sut/lib/fuel.o /tmp/sut/lib/fuel.c
    ar rcs /tmp/sut/lib/libfuel.a /tmp/sut/lib/fuel.o
}

# $1: additional linker flag
buildProgram() {
    mkdir -p /tmp/sut/app
    cat > /tmp/sut/app/main.c <<EOF
extern int calcPrice(int liters);
int main() {
    if (46 != calcPrice(2)) {
        return 1;
    }
    return 0;
}
EOF
    gcc -L/tmp/sut/lib \
        /tmp/sut/app/main.c \
        -o /tmp/sut/app/main \
        -lfuel ${1}
}

# $1: symbol name
verify() {
    nm /tmp/sut/lib/fuel.o | grep -i ${1}
    nm /tmp/sut/app/main | grep -i ${1}
}

goodAllStaticSymbol() {
    buildStaticLib static
    buildProgram
    verify unit
}

exposed() {
    buildStaticLib
    buildProgram
    verify unit
}

readOnly() {
    buildStaticLib "static const" -fPIC
    buildProgram "-Wl,--exclude-libs,libfuel.a"
    verify unit
}

# case 1: mark the global variable static
# d unitPrice
# The symbol is in the initialized data section
# Local visibility
goodAllStaticSymbol

# case 2: global variable is not static
# D unitPrice
# Global visibility!!!
exposed

# case 3: mark the global variable static and read-only (const)
# r unitPrice
# This also hides the symbol - Good!
# -fPIC is irrelevant here. It has no effect.
readOnly
