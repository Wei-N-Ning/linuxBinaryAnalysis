#!/usr/bin/env bash

# source:
# this example came from a problem I found at wt

setUp() {
    set -e
}

buildSUT() {
    cat > /tmp/_.cpp <<EOF
#include <boost/regex.hpp>
#include <string>
int main() {
    boost::regex r(std::string("w+"));
    return 0;
}
EOF
    g++ /tmp/_.cpp -o /tmp/_ -Wl,-lboost_regex
}

runSUT() {
    /tmp/_
}

setUp
buildSUT
readelf -V /tmp/_

