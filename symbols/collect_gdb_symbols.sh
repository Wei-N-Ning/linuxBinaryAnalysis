#!/usr/bin/env bash

# to collect all the symbols
SUTBIN=${1:?"missing executable file path"}
TOP_NAMESPACE=${2:?"missing program top level namespace"}

DBG=${DBG:-gdb}

set -e

TEMPDIR=/tmp/sut
ARTIFACT=/tmp/arti

tearDown() {
    rm -rf ${TEMPDIR} /tmp/_ /tmp/_.* /tmp/__*
}

setUp() {
    tearDown
    mkdir -p ${TEMPDIR}
    mkdir -p ${ARTIFACT}
}

collectNamespace() {
    local oneliner="!/${TOP_NAMESPACE}::/ && next;/^All functions matching|plt$|^0x[0-9a-f]+/ && next;/\s(\S?$TOP_NAMESPACE::.*\$)/ && print \$1;"
    ${DBG} \
-batch \
-ex "start" \
-ex "i func ^${TOP_NAMESPACE}::" \
${SUTBIN} | \
perl -lne "${oneliner}" >${ARTIFACT}/$( basename ${SUTBIN} ).symbols
}

setUp
collectNamespace
tearDown
