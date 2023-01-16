#include <stdio.h>
#include <stdlib.h>

typedef struct Sun_ {
    int age;
    int count;
} Sun;

Sun pass(Sun sun) {
    return (Sun){sun.age + 2, sun.count + 2};
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
    Sun s0 = (Sun){8, 9};
    Sun s1 = pass(s0);
    printf("%s %d\n", "hello world", s1.age);
    return EXIT_SUCCESS;
}
