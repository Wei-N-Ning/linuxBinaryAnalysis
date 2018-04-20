#include <map>
#include <memory>
#include <string>
#include <vector>

using namespace std;
using DemoType = vector<map<string, int>>;

DemoType factory(int size) {
    DemoType dt(size);
    for (int i=size; i--; ) {
        map<string, int> m{{"there is a cow", i}};
        dt.emplace_back(m);
    }
    return dt;
}

void testPmr() {
    allocator<DemoType> alloc;
    DemoType tmp(alloc);
    tmp.reserve(10);
}

int main(int argc, char **argv) {
    auto demoObj = factory(11);
    testPmr();
    [&demoObj]() {
        for (auto &elem : demoObj) {
            if (elem.empty()) {
                continue;
            }
            auto &ent = elem["there is a cow"];
            if (ent == 5) {
                ent = 105;
            }
        }
        demoObj.emplace_back(map<string, int>{{"there is no spoon", 0xDEAD}});
    }();
    return 0;
}
