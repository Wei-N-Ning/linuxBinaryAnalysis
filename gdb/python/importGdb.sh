#!/usr/bin/env bash

function doImport() {
    gdb -batch \
-ex "python import gdb" \
-ex "python print(gdb)"
}

doImport
