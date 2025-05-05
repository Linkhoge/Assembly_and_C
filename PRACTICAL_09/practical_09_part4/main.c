#include <stdio.h>

extern int add(int a, int b, int c);
extern int sub(int a, int b);

int main(int argc, char **argv)
{
  printf("Add result: %d\n", add(4, 6, 2));
  printf("Subtract result: %d\n", sub(10, 4));
  return 0;
}
