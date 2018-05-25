#!/usr/bin/env bash

# source:
#
# https://blogs.oracle.com/linux/8-gdb-tricks-you-should-know-v2
#
# you can just build your command-line like usual, and then put
# "gdb --args" in front to launch gdb with the target program
# and the argument list both set
#
# I find this especially useful if I want to debug a project that
# has some arcane wrapper script that assembles lots of environment
# variables and possibly arguments before launching the actual binary
# (I'm looking at you, libtool). Instead of trying to replicate all
# that state and then launch gdb, simply make a copy of the wrapper,
# find the final "exec" call or similar, and add "gdb --args" in front.

setUp() {
    set -e
}

tearDown() {
    :
}

runGDB() {
    gdb --batch \
-ex "show args" \
-ex "run" \
--args /usr/bin/env python -c "import os;os.environ['USER'] = 'DooM'"
}

setUp
runGDB
tearDown