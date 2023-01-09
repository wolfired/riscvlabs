#include <stdio.h>
#include <stdlib.h>

int add(int x, int y) {
    int z = x + y;
    return z;
}

int main(int argc, char** argv) {
    int x = 1;
    int y = 2;
    int z = add(x, y);
    printf("%d + %d = %d\n", x, y, z);
    printf("%s\n", "hello world");
    return EXIT_SUCCESS;
}
