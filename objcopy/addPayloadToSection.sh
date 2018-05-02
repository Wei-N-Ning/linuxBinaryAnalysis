#!/usr/bin/env bash

outDir="/tmp/lba"

function setUp() {
    rm -rf ${outDir}
    mkdir ${outDir}
}

function buildSUT() {
    sutBin="${outDir}/_.o"
    if ! ( gcc ../_sut/minimal.c -o ${sutBin} )
    then
        echo "fail to build sut"
        exit 1
    fi
}

function buildPayload() {
    payload="${outDir}/_.payload"
    if ! ( dd if=/dev/zero of=${payload} bs=1M count=10 )
    then
        echo "fail to build payload"
        exit 1
    fi
}

function inject() {
    local sectionName=thereisacow
    objcopy --add-section ${sectionName}=${payload} ${sutBin}

    if ! ( ${sutBin} )
    then
        echo "sut failed to run"
        exit 1
    fi

    readelf -S ${sutBin} | awk "/${sectionName}/ { print \$2 }"
}

setUp
buildSUT
buildPayload
inject
