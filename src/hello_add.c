#include <stdio.h>
#include <stdlib.h>

typedef struct Sun_ {
    int age;
    int count;
} Sun;

Sun pass(int age, int count) {
    return (Sun){age, count};
}

int add(int x, int y) {
    int z = x + y;
    return z;
}

int main(int argc, char** argv) {
    int x = 1;
    int y = 2;
    int z = add(x, y);
    printf("%d + %d = %d\n", x, y, z);
    Sun s = pass(9, 8);
    printf("%s %d\n", "hello world", s.age);
    return EXIT_SUCCESS;
}
