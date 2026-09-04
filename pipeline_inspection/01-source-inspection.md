# Source Code Inspection .c
## Objective

Understand the source-level structure of the project before compilation.

At this stage, I am inspecting three related file types:
```c
.c  → C source / implementation
.h  → declarations / interface
```
### my goal is to understand:

Where functions are implemented
Where functions are declared
Where functions are called
How .c files use .h files
How these files are connected before compilation begins

At this stage, I am only inspecting the source code.
I am not yet looking at preprocessing, assembly, object files, or linking.
## What I Am Inspecting
```c
c/
├── inc/
│   ├── add.h
│   ├── sub.h
│   ├── mul.h
│   └── div.h
│
└── src/
    ├── add.c
    ├── sub.c
    ├── mul.c
    └── div.c
```

For detailed inspection, I am focusing on:

main.c
add.c
add.h

avatar@gzb:~/Projects/ELF-Binary-Explorer$ **cat main.c**
```c
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
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/add.c
```c
#include "add.h"

int add(int a, int b)
{
    return a + b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/sub.c
```c
include "sub.h"

int sub(int a, int b)
{
    return a - b;
}
```

avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/mul.c
```c
#include "mul.h"

int mul(int a, int b)
{
    return a * b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/src/div.c
```c
#include "div.h"

int divide(int a, int b)
{
    if (b == 0)
    {
        return 0;
    }

    return a / b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/inc/add.h
```c
#ifndef ADD_H
#define ADD_H

int add(int a, int b);
#endif
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/inc/sub.h
```c
#ifndef SUB_H
#define SUB_H

int sub(int a, int b);

#endif
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/inc/mul.h
```c
#ifndef MUL_H
#define MUL_H

int mul(int a, int b);

#endif
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat c/inc/div.h
```c
#ifndef DIV_H
#define DIV_H

int divide(int a, int b);
```
What Is Happening in main.c?

main.c contains the main() function.

int main(void)
{
    ...
}

This is the definition of main() because the function body is present.

Inside main(), the program calls several functions:

printf(...)
scanf(...)
add(a, b)
sub(a, b)
mul(a, b)
divide(a, b)

So main.c is both:

main.c
 ├── defines main()
 └── calls other functions
 add() — Declaration, Definition and Call

Declaration — add.h
int add(int a, int b);      This is a function declaration,There is no function body here ,It tells the compiler
                                 Function name → add
                                 Arguments     → int, int
                                 Return type   → int
add.h
└── declaration of add()
Definition — add.c        
int add(int a, int b)
{
    return a + b;          This is the function definition,Here the actual function body exists "return a + b;"
}   
Inside main():  add(a, b)  This is the function call
```c
add.h
  │
  │ declaration
  ▼
main.c
  │
  │ call
  ▼
add()
  ▲
  │
  │ definition
  │
add.c
```
main.c does not contain the body of add().
add.h does not contain the body of add().
The body is in: c/src/add.c

### when main.c calls:   add(a, b)
the compiler has already seen the declaration of add().

#include "add.h"(So the compiler knows: add is a function that accepts two integers and returns an integer. The actual implementation is still in add.c.)


#include <stdio.h>   This gives the source file access to declarations provided by the standard I/O header.
For example, main.c calls:

printf(...)
scanf(...)

But their function bodies are not written inside main.c.



```c
Conceptually:

main.c
  │
  │ #include <stdio.h>
  ▼
stdio.h
  │
  │ declarations
  ▼
printf()
scanf()
```

### Where Is the Definition of printf()?
This is an important distinction.
stdio.h provides the declarations/interface needed by the compiler.
It does not mean that the complete implementation of printf() is sitting inside your main.c.

The actual implementation comes from the C standard library provided by the system.

So conceptually:
```c
stdio.h
   │
   │ declaration
   ▼
main.c
   │
   │ call
   ▼
printf()
   │
   │ actual implementation
   ▼
C standard library
```
## The exact library/runtime details will become much clearer when we inspect the object files and linking stages.

7. Comparing add() With printf()

The difference is where the implementation lives.

For add():  your project → add.c
For printf(): system C library
# What I Learned
.c
→ contains C source code and function definitions/calls
.h
→ contains function declarations/interfaces

Function declaration
→ tells the compiler about the function

Function definition
→ contains the actual function body

Function call
→ uses/invokes the function

For my add() function:

add.h
→ declaration

add.c
→ definition

main.c
→ call

For standard I/O:

stdio.h
→ declarations for functions such as printf() and scanf()

main.c
→ calls printf() and scanf()

C standard library
→ provides their implementation
```c
At This Stage: What I Know
✓ What a .c file contains
✓ What a .h file contains
✓ Declaration vs definition vs call
✓ main.c defines main()
✓ main.c calls add()
✓ add.h declares add()
✓ add.c defines add()
✓ main.c calls printf() and scanf()
✓ stdio.h provides their declarations
✓ printf()/scanf() implementations are provided by the system C library
✓ #include makes header declarations available to the source file

At This Stage: What I Do NOT Know
✗ What exactly happens to #include
✗ What main.c looks like after headers are included
✗ What add.h looks like after preprocessing
✗ What printf() and add() look like after compilation
✗ How C code becomes assembly
✗ How add.c becomes add.o
✗ How main.o refers to add()
✗ How the linker connects main.o with add.o
✗ How the C library is connected to printf() and scanf()
 .c file contains C source code.
```
