
#include <memory>
#include <vector>

using Vec = std::vector<int>;
using SPVec = std::shared_ptr<Vec>;

SPVec create(int size) {
    return SPVec(new Vec(size, 2));
}

void repopulate(SPVec &spVec, int num, int value) {
    for (int i=num; i--; ) {
        spVec->emplace_back(value);
    }
}

void reset(SPVec &spVec) {
    while (! spVec->empty()) {
        spVec->pop_back();
    }
}

int main(int argc, char **argv) {
    auto spVec = create(1);
    repopulate(spVec, 10, 23);
    reset(spVec);
    return 0;
}

