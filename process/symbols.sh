#!/usr/bin/env bash

# usage: 
# symbols pid

# $1: pid of an existing process
# $2: (optional) output file path, by default is /tmp/out.txt
#
# NOTE:
# for a heavy process (motionbuilder) the symbol list can be as large as 200M
#
# TODO:
# 1) only collect the dynamic symbols (50% of weight), make it configurable
# 2) filter out unwanted binary files (e.g. only collect from /vol, /digi, /lib)
function dumpSymbols() {
    local _pid=${1:?missing pid}
    local outPath=${2:-/tmp/out.txt}
    rm -f ${outPath}
    pmap -p ${_pid} |\
    awk '
{ 
    if (match($4, "^/")) {
        arr[$4] = $4
    }    
}
END {
    n = asort(arr)
    for (i=1; i<=n; i++) {
        print arr[i]
    }
}
' | xargs nm -D -C --format=posix 1>>${outPath} 2>/dev/null
}

# $1: file path of the symbol list
# 
# TODO:
# ability to configure the filter
function analyseSymbols() {
    awk '
{
    if (match($1, "^[^/]")) {
        arr[$1] = $1
    }
}
END {
    n = asort(arr)
    for (i=1; i<=n; i++) {
        print arr[i]
    }
}
' ${1}
}

function run() {
    local _pid=${1:?missing pid}
    local outPath=${2:-/tmp/out.txt}
    if ! ( ps ${_pid} 0>/dev/null 1>/dev/null )
    then
        echo "process does not exist: ${_pid}"
        exit 1
    fi
    dumpSymbols ${_pid} ${outPath}
    analyseSymbols ${outPath}
}

run $1 $2
