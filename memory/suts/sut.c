#include <stdio.h>
#include <unistd.h>
int main(int argc, char **argv) {
    while (fopen("/tmp/poisonpill", "r") == NULL) {
        sleep(0.5);
    }
    return 0;
}
