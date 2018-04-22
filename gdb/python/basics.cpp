#include <vector>

template<typename T>
struct Foo {
    T t;
    bool flag;
    std::vector<T> store;
};
using IFoo = Foo<int>;
using DFoo = Foo<double>;

IFoo createIFoo(int v) {
    IFoo ins;
    ins.t = v;
    return ins;
}

DFoo createDFoo(double v) {
    DFoo ins;
    ins.t = v;
    return ins;
}

int main() {
    auto i = createIFoo(10);
    auto d = createDFoo(10.1);
    return 0;
}
