# Preprocessor Inspection — .i
## Objective

Understand what happens to the .c source files during preprocessing.

At this stage, I want to see what happens to:

#include <stdio.h>
#include "add.h"
#include "sub.h"
#include "mul.h"
#include "div.h"

The main question is:

What does the source code look like after the header files have been included?

I am inspecting the generated .i files
```c
.c + .h
   │
   │ preprocessor
   ▼
  .i
```
```c
The .i file is still C source code. It is not assembly and it is not machine code.
What I Am Inspecting

Generated files:

pipeline_inspection/
└── preprocess/
    ├── main.i
    ├── add.i
    ├── sub.i
    ├── mul.i
    └── div.i

For detailed inspection, I am focusing on:

main.i
add.i
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat pipeline_inspection/preprocess/add.i
```c
# 0 "c/src/add.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "c/src/add.c"
# 1 "c/inc/add.h" 1

int add(int a, int b);
# 2 "c/src/add.c" 2

int add(int a, int b)
{
    return a + b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat pipeline_inspection/preprocess/sub.i
```c
# 0 "c/src/sub.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "c/src/sub.c"
# 1 "c/inc/sub.h" 1



int sub(int a, int b);
# 2 "c/src/sub.c" 2

int sub(int a, int b)
{
    return a - b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat pipeline_inspection/preprocess/mul.i
```c
# 0 "c/src/mul.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "c/src/mul.c"
# 1 "c/inc/mul.h" 1



int mul(int a, int b);
# 2 "c/src/mul.c" 2

int mul(int a, int b)
{
    return a * b;
}
```
avatar@gzb:~/Projects/ELF-Binary-Explorer$ cat pipeline_inspection/preprocess/div.i
```c
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
```
```c
Inspecting add.i
What changed?
Original add.c:

#include "add.h"
int add(int a, int b)
{
    return a + b;
}

After preprocessing:

int add(int a, int b);
int add(int a, int b)
{
    return a + b;
}

The important observation is:

#include "add.h"
        │
        │ preprocessing
        ▼
int add(int a, int b);

The contents of add.h have been inserted into the preprocessed source.
```
2. Connecting add.h → add.c → add.i
```c
Original header (add.h)
int add(int a, int b);

Original source(add.c)
#include "add.h"
int add(int a, int b)
{
    return a + b;
}

Now see after preprocessing:

int add(int a, int b);
int add(int a, int b)
{
    return a + b;
}

So the preprocessor has effectively produced one source file containing:

declaration
    +
definition

The important point:

The preprocessor does not move the function implementation from add.c somewhere else. It processes the #include and produces a preprocessed translation unit containing the header contents and the original source.
```
```c
3. Preprocessor Line Markers

The .i file contains lines such as:
# 1 "c/src/add.c"
# 1 "c/inc/add.h" 1
...
# 2 "c/src/add.c" 2

These are preprocessor line markers,They tell the compiler where the following source text originally came from
For example: # 1 "c/inc/add.h" 1 this line means this comes from c/inc/add.h
```
## Inspecting main.i

Command: cat pipeline_inspection/preprocess/main.i
```
The complete output is very large because main.c includes:

#include <stdio.h> and stdio.h includes many other system headers
I do not need to paste the entire file into my learning notes.I will extract the useful parts.
stdio.h Was Included ,In main.i, I can see:  # 1 "/usr/include/stdio.h" 1 3 4  This shows that the preprocessor entered:/usr/include/stdio.h
Then many other system headers appear because stdio.h itself includes additional headers.
For example:
/usr/include/features.h
/usr/include/x86_64-linux-gnu/bits/types.h
/usr/lib/gcc/x86_64-linux-gnu/15/include/stddef.h

extern int printf (const char *__restrict __format, ...);
This came from the included stdio.h.

Therefore:

main.c
   │
   │ #include <stdio.h>
   ▼
stdio.h
   │
   │ declaration
   ▼
extern int printf(...);

So after preprocessing, the declaration of printf() is present in the .i file.

 scanf() Declaration in main.i

Another useful part is:

extern int scanf (const char *__restrict __format, ...) __asm__ ("" "__isoc23_scanf");

The exact declaration contains compiler-specific attributes and naming details.

For my learning, the important part is:

scanf()

has a declaration coming from stdio.h.

Therefore:

stdio.h
   │
   │ declaration
   ▼
main.i
   │
   │ used by
   ▼
main.c
```

##  Project Headers in main.i
```c
Near the end of main.i, I can see:

# 1 "c/inc/add.h" 1
...
int add(int a, int b);

# 1 "c/inc/sub.h" 1
...
int sub(int a, int b);

# 1 "c/inc/mul.h" 1
...
int mul(int a, int b);

# 1 "c/inc/div.h" 1
...
int divide(int a, int b);

This is the most useful part for understanding my own project headers.

The original:

#include "add.h"
#include "sub.h"
#include "mul.h"
#include "div.h"

has resulted in their declarations appearing in the .i file.
```
## Note ----> main() Is Still Present
```c
After the included headers, main.i contains the original program:
int main(void)
{
    int a = 20;
    int b = 5;
    int choice;

    ...
}

The function calls are still written as C:

printf(...);
scanf(...);

add(a, b);
sub(a, b);
mul(a, b);
divide(a, b);
The preprocessor has not converted these calls into assembly instructions.
*********They are still C statements************.

 Useful main.i Structure

For learning, I can reduce the huge main.i conceptually to:

system headers
     │
     ├── printf() declaration
     ├── scanf() declaration
     └── other required declarations
     
project headers
     │
     ├── add() declaration
     ├── sub() declaration
     ├── mul() declaration
     └── divide() declaration

original main.c
     │
     └── main() definition
             │
             ├── printf() call
             ├── scanf() call
             ├── add() call
             ├── sub() call
             ├── mul() call
             └── divide() call

This is the useful information hidden inside the large .i file.
```
```c
What I Learned
✓ The preprocessor processes #include directives
✓ The contents of project headers appear in the .i file
✓ add.h's declaration appears in add.i
✓ add.h, sub.h, mul.h and div.h declarations appear in main.i
✓ stdio.h is processed when main.c includes it
✓ printf() and scanf() declarations become visible in main.i
✓ Header inclusion can bring in many other system headers
✓ This is why main.i is much larger than main.c
✓ .i is still C source code
✓ Preprocessing happens before compilation into assembly
The most important transformation I observed:

add.c
   │
   ├── #include "add.h"
   │
   ▼
add.i
   │
   ├── add.h declaration
   └── add.c implementation

And for main.c:

main.c
   │
   ├── #include <stdio.h>
   ├── #include "add.h"
   ├── #include "sub.h"
   ├── #include "mul.h"
   └── #include "div.h"
   │
   ▼
main.i
   │
   ├── system header declarations
   ├── add() declaration
   ├── sub() declaration
   ├── mul() declaration
   ├── divide() declaration
   └── main() + original program code
```
```c
At This Stage: What I Know
✓ What a .i file is
✓ Why .i files are larger than .c files
✓ What happens to #include
✓ How add.h appears inside add.i
✓ How project headers appear inside main.i
✓ How stdio.h contributes printf()/scanf() declarations
✓ That header contents become part of the preprocessed source
✓ That .i is still C source code
✓ That preprocessing happens before compilation

At This Stage: What I Do NOT Know
✗ How C statements become assembly instructions
✗ How int variables are represented in assembly
✗ How add(a, b) becomes a machine-level function call
✗ How arguments are passed to add()
✗ How add() returns its result
✗ What .text and .rodata sections are
✗ What @PLT means in a function call
✗ What an ELF .o file contains
✗ How symbols and relocations work
```
