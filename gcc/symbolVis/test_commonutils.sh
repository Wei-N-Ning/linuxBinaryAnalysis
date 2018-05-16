#!/usr/bin/env sh
bash -c "source commonutils.sh;setUp;test -d /tmp/_sut && echo 'pass';tearDown; test -d /tmp/_sut && echo 'fail'"
