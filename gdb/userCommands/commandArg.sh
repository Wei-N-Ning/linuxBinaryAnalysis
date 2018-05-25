#!/usr/bin/env bash

# how create a GDB command and pass arguments to it

function createPythonModule() {
    echo "from __future__ import print_function
import gdb
class NewCommand(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, 'new-cmd', gdb.COMMAND_STACK, gdb.COMPLETE_NONE)
    def invoke(self, args, from_tty):
        print('args:', args, from_tty)
NewCommand()" > /tmp/newCommand.py
}

function runGDB() {
    cd /tmp
    gdb --batch \
-ex "py import newCommand" \
-ex "new-cmd 123 asd"
}

createPythonModule
runGDB
