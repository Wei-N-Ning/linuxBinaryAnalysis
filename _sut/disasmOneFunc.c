//
// Created by wein on 4/14/18.
//

#include <assert.h>

struct Unpacked {
    int a;
    char b;
    int c;
    char t;
};

struct Packed {
    int a;
    int c;
    char b;
    char t;
};

void test_nothing() {
    assert(16 == sizeof(struct Unpacked));
    assert(12 == sizeof(struct Packed));
}

int main(int argc, char **argv) {
    test_nothing();
    struct Unpacked u;
    struct Packed p;
    return 0;
}
