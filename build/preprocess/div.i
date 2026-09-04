# 0 "c/src/div.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "c/src/div.c"
# 1 "c/inc/div.h" 1



int divide(int a, int b);
# 2 "c/src/div.c" 2

int divide(int a, int b)
{
    if (b == 0)
    {
        return 0;
    }

    return a / b;
}
