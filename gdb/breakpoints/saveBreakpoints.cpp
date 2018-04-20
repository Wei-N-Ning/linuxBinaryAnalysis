
#include <memory>
#include <vector>

using Vec = std::vector<int>;
using SPVec = std::shared_ptr<Vec>;

SPVec create(int size) {
    return SPVec(new Vec(size, 2));
}

void repopulate(SPVec &spVec) {
    for (auto &elem : *spVec) {
        elem = 13;
    }
}

void reset(SPVec &spVec) {
    while (! spVec->empty()) {
        spVec->pop_back();
    }
}

int main(int argc, char **argv) {
    auto spVec = create(10);
    repopulate(spVec);
    reset(spVec);
    return 0;
}

