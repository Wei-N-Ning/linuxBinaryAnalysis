#include <vector>

struct Shell {
    double damage;
    double radius;
    double velocity;
};

struct Explosive {
    double damage;
    double radius;
    double velocity;
};

template<typename T>
struct Magzine {
    std::vector<T> ammos;
};

using ShellMagzine = Magzine<Shell>;
using ExplosiveMagzine = Magzine<Explosive>;

template<typename T, typename U>
void fire(T &t, U &u) {
    ;
}

int main() {
    ShellMagzine shellMagzine;
    ExplosiveMagzine explosiveMagzine;
    fire(shellMagzine, explosiveMagzine);
    return 0;
}
