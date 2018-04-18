#!/usr/bin/env bash

function gdbDirArgs() {
    python -c "
import os
import sys
rootDir = sys.argv[1]
extensions = set(['.{}'.format(_) for _ in sys.argv[2:]])
dirs = set()
for curDir, subDirs, fileNames in os.walk(rootDir):
    for fileName in fileNames:
        if os.path.splitext(fileName)[-1] not in extensions:
            continue
        dirs.add('-d {}'.format(curDir))
print ' '.join(dirs)
" ${@} 2>/dev/null
}

function run() {
    gdb $( gdbDirArgs /work/dev/c/github.com/powergun/cexamples/tests c h hpp py ) -batch -ex "show directories"
}

run
