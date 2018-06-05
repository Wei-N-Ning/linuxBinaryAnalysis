#!/usr/bin/env bash

# note:
# to clean up the source listing, use:
# | awk '{print substr($0, 3, 99)}'

setUp() {
    set -e
}

buildSUT() {
    cat > /tmp/_.c <<EOF
int main() {
    //
    //
    //
    //
    int a = 10;
    for (int i=0; i<a; ++i) {
        ;
    }
    a = 20;
    return 0;
}
EOF
    gcc -g -o /tmp/_ /tmp/_.c
}

runGDB() {
    gdb -quiet -batch \
-ex "start" \
-ex "list _.c:1,99" \
-ex "cont" \
/tmp/_
}

setUp
buildSUT
runGDB