#!/usr/bin/env bash

# source
#
# https://blogs.oracle.com/linux/8-gdb-tricks-you-should-know-v2

setUp() {
    set -e
}

# requires boost to be installed in the default system
# location; if not, use -I
buildSUT() {
    echo "
#include <cassert>
#include <boost/preprocessor/seq/size.hpp>
#define TUPLE (1, 2, 3, 4)
#define SEQUENCE (1) (2) (3)
int main(int argc, char **argv) {
    assert(3 == BOOST_PP_SEQ_SIZE(SEQUENCE));
    return 0;
}
" > /tmp/_.cpp
    g++ -ggdb3 -std=c++11 -o /tmp/_ /tmp/_.cpp
}

# useful:
# info macro xxx
# macro expand xxx
runGDB() {
    gdb --batch \
-ex "start" \
-ex "info macro BOOST_PP_SEQ_SIZE" \
-ex "macro expand BOOST_PP_SEQ_SIZE(SEQUENCE)" \
-ex "run" \
/tmp/_
}

setUp
buildSUT
runGDB
