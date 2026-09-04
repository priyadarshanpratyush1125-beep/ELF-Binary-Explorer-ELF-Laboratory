# Source Code Inspection (.c files)

## Files Inspected
- main.c
- c/src/add.c
- c/src/sub.c
- c/src/mul.c
- c/src/div.c

avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat main.c
'''
#include <stdio.h>

#include "add.h"
#include "sub.h"
#include "mul.h"
#include "div.h"

int main(void)
{
    int a = 20;
    int b = 5;
    int choice;

    printf("C Compilation Pipeline Calculator\n");
    printf("---------------------------------\n");

    printf("a = %d\n", a);
    printf("b = %d\n\n", b);

    printf("1. Addition\n");
    printf("2. Subtraction\n");
    printf("3. Multiplication\n");
    printf("4. Division\n");

    printf("\nEnter your choice: ");
    scanf("%d", &choice);

    switch (choice)
    {
        case 1:
            printf("Result: %d\n", add(a, b));
            break;

        case 2:
            printf("Result: %d\n", sub(a, b));
            break;

        case 3:
            printf("Result: %d\n", mul(a, b));
            break;

        case 4:
            printf("Result: %d\n", divide(a, b));
            break;

        default:
            printf("Invalid choice!\n");
    }

    return 0;
'''
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/add.cc
#include "add.h"

int add(int a, int b)
{
    return a + b;
}avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/sub.c
#include "sub.h"

int sub(int a, int b)
{
    return a - b;
}avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/mul.c
#include "mul.h"

int mul(int a, int b)
{
    return a * b;
}avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/div.c
#include "div.h"

int divide(int a, int b)
{
    if (b == 0)
    {
        return 0;
    }

    return a / b;

## Dependencies (gcc -M)
first create dependencies file (.d) 
avatar@gzb:~/Projects/ELF-Binary-Explorer$mkdir -p pipeline_inspection/dependenciess
gcc -M main.c -I c/inc > pipeline_inspection/dependencies/main.d
gcc -M c/src/add.c -I c/inc > pipeline_inspection/dependencies/add.d
gcc -M c/src/sub.c -I c/inc > pipeline_inspection/dependencies/sub.d
gcc -M c/src/mul.c -I c/inc > pipeline_inspection/dependencies/mul.d
gcc -M c/src/div.c -I c/inc > pipeline_inspection/dependencies/div.d

# now inspect add.d and main.d


avatar@gzb:~/Projects/ELF-Binary-Explorer/pipeline_inspection/dependencies$ cat add.d
add.o: c/src/add.c /usr/include/stdc-predef.h c/inc/add.h
avatar@gzb:~/Projects/ELF-Binary-Explorer/pipeline_inspection/dependencies$ cat main.d
main.o: main.c /usr/include/stdc-predef.h /usr/include/stdio.h \
 /usr/include/x86_64-linux-gnu/bits/libc-header-start.h \
 /usr/include/features.h /usr/include/features-time64.h \
 /usr/include/x86_64-linux-gnu/bits/wordsize.h \
 /usr/include/x86_64-linux-gnu/bits/timesize.h \
 /usr/include/x86_64-linux-gnu/sys/cdefs.h \
 /usr/include/x86_64-linux-gnu/bits/long-double.h \
 /usr/include/x86_64-linux-gnu/gnu/stubs.h \
 /usr/include/x86_64-linux-gnu/gnu/stubs-64.h \
 /usr/lib/gcc/x86_64-linux-gnu/15/include/stddef.h \
 /usr/lib/gcc/x86_64-linux-gnu/15/include/stdarg.h \
 /usr/include/x86_64-linux-gnu/bits/types.h \
 /usr/include/x86_64-linux-gnu/bits/typesizes.h \
 /usr/include/x86_64-linux-gnu/bits/time64.h \
 /usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h \
 /usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h \
 /usr/include/x86_64-linux-gnu/bits/types/__fpos64_t.h \
 /usr/include/x86_64-linux-gnu/bits/types/__FILE.h \
 /usr/include/x86_64-linux-gnu/bits/types/FILE.h \
 /usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h \
 /usr/include/x86_64-linux-gnu/bits/types/cookie_io_functions_t.h \
 /usr/include/x86_64-linux-gnu/bits/stdio_lim.h \
 /usr/include/x86_64-linux-gnu/bits/floatn.h \
 /usr/include/x86_64-linux-gnu/bits/floatn-common.h c/inc/add.h \
 c/inc/sub.h c/inc/mul.h c/inc/div.h

 ## Symbol Analysis
 
What’s in the Code?
main.c – The brain. It prints a menu, asks the user for a choice, and calls one of four math functions. It doesn’t know how to add or subtract—it only knows what to call.

add.c, sub.c, mul.c, div.c – The workers. Each contains the actual math logic. They are independent modules.

2. Symbols – What’s Defined and What’s Undefined?
Symbol	         Where is it defined?	                  Where is it used?
main	         main.c (defined)	                       –
add	add.c        (defined)	                              Called in main.c
sub	sub.c        (defined)	                              Called in main.c
mul	mul.c        (defined)	                              Called in main.c
divide	         div.c (defined)	                      Called in main.c
printf	         NOT defined in our code
                 comes from libc (external)               Called in main.c
scanf	         NOT defined in our code            
                 comes from libc (external)           	  Called in main.c

Defined symbols = the actual code we wrote.

Undefined symbols = promises to the linker: “I will find them later from libraries.”

3. Why Do We Need a Linker?
The compiler compiles main.c and add.c separately. When compiling main.c, the compiler does not know the address of add() – it only knows it exists (because of add.h). So it leaves a placeholder (a relocation entry).

The linker’s job is to combine all .o files and replace those placeholders with the real addresses of add, sub, mul, divide (and also printf, scanf from libc).

4. Key Insight
The separation of declaration (headers) and definition (.c files) allows us to compile each file independently. The linker is the glue that stitches everything together into a working executable.

5. must know----
Q1: Why does main.c include add.h but not add.c?
A1: The header tells the compiler how to call add. The actual code (.c) is compiled separately and linked later.

Q2: What would happen if we forgot to link add.o?
A2: The linker would complain about an undefined reference to add, and the build would fail.

Q3: Are printf and scanf also undefined?
A3: Yes, but the linker finds them in the C standard library (usually libc.so or libc.a) automatically when we use gcc (unless we use -nostdlib).

Q4: Why can’t the compiler just put the final addresses of add in main.o?
A4: Because the final address depends on how the linker arranges the final executable. The compiler cannot know that in advance; that’s why we need relocation.

