#!/usr/bin/env bash

# TODO: source

CXX=${CXX:-g++}

instru_src=/tmp/instru_src.cpp
generateInstrumentSource() {
    cat > ${instru_src} << "EOF"
#include <cstdio>
extern "C" void __cyg_profile_func_enter(void *this_fn, void *call_site) {
    printf("calling: %p\n", call_site);
}
extern "C" void __cyg_profile_func_exit(void *this_fn, void *call_site) {
    printf("leaving: %p\n", call_site);
}
EOF
}

src=/tmp/src.cpp
srcbin=/tmp/out.bin
buildSUT() {
    echo "int main() { return 0; }" >${src}
    ${CXX} \
-std=c++11 \
-finstrument-functions \
-finstrument-functions-exclude-file-list=instru_src \
-frecord-gcc-switches \
${src} ${instru_src} \
-o ${srcbin}
}

runSUT() {
    ${srcbin}
}

generateInstrumentSource
buildSUT
runSUT


