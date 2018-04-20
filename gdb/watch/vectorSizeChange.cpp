#include <vector>

using DemoType = std::vector<int>;

void modify(DemoType &dt) {
    dt.emplace_back(10);
    dt.emplace_back(10);
    dt.emplace_back(10);
    dt.emplace_back(10);
    dt.emplace_back(10);
}

int main(int argc, char **argv) {
    DemoType dt;
    modify(dt);
    return 0;
}
