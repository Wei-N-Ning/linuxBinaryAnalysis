#!/usr/bin/env bash

function gdbDirArgs() {
    python -c "
import os
import sys
rootDir = sys.argv[1]
extensions = set()
excludedDirs = set()
for arg_ in sys.argv[2:]:
    if arg_.startswith('-'):
        excludedDirs.add(arg_[1:])
    else:
        extensions.add('.{}'.format(arg_)) 
dirs = set()
for curDir, subDirs, fileNames in os.walk(rootDir):
    subDirs[:] = [d for d in subDirs if d not in excludedDirs]
    for fileName in fileNames:
        if os.path.splitext(fileName)[-1] not in extensions:
            continue
        dirs.add('-d {}'.format(curDir))
print ' '.join(dirs)
" ${@}
}

function run() {
    gdb $( gdbDirArgs /work/dev/c/github.com/powergun/cexamples c h -.git -build -cmake-build-debug ) -batch -ex "show directories"
}

run
