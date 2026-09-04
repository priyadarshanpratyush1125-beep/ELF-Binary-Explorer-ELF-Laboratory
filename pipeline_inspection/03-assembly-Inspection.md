# Assembly Inspection (`.s`)

## Objective

Understand how the C compiler converts C code into **assembly language** before it becomes machine code.

At this stage I am mainly looking at:

* registers
* function arguments and return values
* stack/frame
* arithmetic instructions
* conditional branches
* function calls

---

## What I Am Inspecting

Assembly files generated from each C source file:

```text
build/assembly/
├── main.s
├── add.s
├── sub.s
├── mul.s
└── div.s
```

The important idea is:

```text
.c  →  preprocessor  →  .i  →  compiler  →  .s
```

The `.s` file is still **human-readable text**, but now the C statements have been translated into CPU instructions.

---

# 1. `add.c` → `add.s`

C code:

```c
int add(int a, int b)
{
    return a + b;
}
```

Important assembly:

```asm
add:
    movl    %edi, -4(%rbp)
    movl    %esi, -8(%rbp)

    movl    -4(%rbp), %edx
    movl    -8(%rbp), %eax

    addl    %edx, %eax
    ret
```

### What is happening?

On x86-64 Linux, the first integer arguments are passed through registers.

For this function:

```text
a → %edi
b → %esi
```

Then:

```asm
addl %edx, %eax
```

means approximately:

```text
eax = eax + edx
```

The return value is placed in:

```text
%eax
```

So conceptually:

```text
a → register
b → register
   ↓
ADD instruction
   ↓
%eax
   ↓
return value
```

### Important instructions

| Assembly | Meaning                 |
| -------- | ----------------------- |
| `movl`   | copy 32-bit value       |
| `addl`   | integer addition        |
| `subl`   | integer subtraction     |
| `imull`  | integer multiplication  |
| `idivl`  | signed integer division |
| `ret`    | return from function    |

---

# 2. `sub.c` → `sub.s`

C:

```c
return a - b;
```

Important instruction:

```asm
movl    -4(%rbp), %eax
subl    -8(%rbp), %eax
```

Conceptually:

```text
eax = a
eax = eax - b
```

So:

```text
C:        a - b
Assembly: subl
```

---

# 3. `mul.c` → `mul.s`

C:

```c
return a * b;
```

Important instruction:

```asm
movl    -4(%rbp), %eax
imull   -8(%rbp), %eax
```

Conceptually:

```text
eax = a
eax = eax * b
```

So:

```text
C:        a * b
Assembly: imull
```

---

# 4. `div.c` → `div.s`

C:

```c
if (b == 0)
{
    return 0;
}

return a / b;
```

Important assembly:

```asm
cmpl    $0, -8(%rbp)
jne     .L2

movl    $0, %eax
jmp     .L3

.L2:
    movl    -4(%rbp), %eax
    cltd
    idivl   -8(%rbp)
```

### This is very important

The C condition:

```c
if (b == 0)
```

becomes:

```asm
cmpl $0, -8(%rbp)
jne  .L2
```

The compiler has converted a high-level `if` into:

```text
compare
   ↓
conditional jump
   ↓
different code path
```

This is the beginning of understanding how **control flow works at CPU level**.

---

# 5. `main.c` → `main.s`

`main.s` is more interesting because it contains:

* local variables
* function calls
* `switch`
* strings
* branches
* stack management

For example:

```c
int a = 20;
int b = 5;
```

becomes:

```asm
movl    $20, -16(%rbp)
movl    $5, -12(%rbp)
```

So the values are stored in memory locations relative to the stack frame.

Conceptually:

```text
Stack frame

rbp
 ↓
+----------------+
| saved data     |
+----------------+
| a = 20         |
+----------------+
| b = 5          |
+----------------+
| choice         |
+----------------+
```

---

# 6. Function Calls

This is one of the most important parts of `main.s`.

C:

```c
add(a, b)
```

Assembly:

```asm
movl    -12(%rbp), %edx
movl    -16(%rbp), %eax
movl    %edx, %esi
movl    %eax, %edi
call    add@PLT
```

The important instruction is:

```asm
call add@PLT
```

This means:

> Call the function named `add`.

The arguments are prepared in registers first:

```text
a → %edi
b → %esi
```

Then:

```text
call add
```

The result comes back in:

```text
%eax
```

This is extremely important for understanding **how functions communicate at machine level**.

---

# 7. `printf()` and `scanf()`

In `main.s` you can see:

```asm
call    printf@PLT
```

and:

```asm
call    __isoc23_scanf@PLT
```

Notice something important:

The assembly contains the **call**, but not the implementation of `printf()`.

Similarly:

```asm
call add@PLT
```

does not contain the implementation of `add()` inside `main.s`.

Why?

Because each `.c` file is compiled separately.

```text
main.c → main.s
add.c  → add.s
sub.c  → sub.s
mul.c  → mul.s
div.c  → div.s
```

The actual connection between these functions will be handled later by the **linker**.

---

# 8. What Does `@PLT` Mean?

You will see:

```asm
call printf@PLT
call add@PLT
call sub@PLT
```

For now, remember only this:

**PLT = Procedure Linkage Table**

It is part of the mechanism used to call functions whose final addresses are not yet fixed at this stage.

This becomes important when we study:

```text
.o
 ↓
linker
 ↓
ELF executable
```

and later:

```text
shared libraries
dynamic linker
PLT/GOT
```

Don't try to fully understand PLT/GOT yet.

---

# 9. Registers You Should Know

For this project, these are the important x86-64 registers:

```text
%rax / %eax   → return value / general purpose
%rdi / %edi   → 1st integer argument
%rsi / %esi   → 2nd integer argument
%rdx / %edx   → 3rd integer argument
%rsp           → stack pointer
%rbp           → base/frame pointer
```

For example:

```asm
movl %eax, %edx
```

means:

```text
copy value from eax → edx
```

The `l` suffix means the 32-bit form of the register/instruction.

---

# 10. Function Prologue and Epilogue

Most functions begin with something like:

```asm
pushq   %rbp
movq    %rsp, %rbp
```

This sets up the function's stack frame.

At the end:

```asm
popq    %rbp
ret
```

This restores the previous stack state and returns to the caller.

Conceptually:

```text
CALL
 ↓
create stack frame
 ↓
execute function
 ↓
restore stack frame
 ↓
RET
```

This is fundamental to understanding:

* function calls
* stack
* local variables
* recursion
* debugging
* buffer overflows
* calling conventions

---

# 11. Strings in `.rodata`

`main.s` contains:

```asm
.section .rodata

.LC0:
    .string "C Compilation Pipeline Calculator"

.LC2:
    .string "a = %d\n"
```

`.rodata` means **read-only data**.

The strings used by `printf()`/`puts()` are stored here.

Then the code obtains their addresses:

```asm
leaq .LC2(%rip), %rdx
```

and passes the address to the function.

So:

```text
"C Compilation Pipeline Calculator"
              ↓
          .rodata
              ↓
          memory address
              ↓
          printf/puts
```

---

# 12. `switch` Becomes Branches

C:

```c
switch (choice)
{
    case 1:
        ...
    case 2:
        ...
    case 3:
        ...
    case 4:
        ...
}
```

Assembly contains:

```asm
cmpl    $4, %eax
je      .L2

cmpl    $3, %eax
je      .L4

cmpl    $1, %eax
je      .L5

cmpl    $2, %eax
je      .L6
```

So the compiler converts the high-level `switch` into **comparisons and jumps**.

Conceptually:

```text
choice
  ↓
compare
  ↓
conditional jump
  ├── case 1
  ├── case 2
  ├── case 3
  ├── case 4
  └── default
```

---

# What I Learned

* `.s` is assembly language generated from C.
* C arithmetic becomes CPU instructions such as `addl`, `subl`, `imull`, and `idivl`.
* Function arguments are passed through registers according to the x86-64 calling convention.
* Integer return values are normally returned through `%eax`.
* `call` is used to call functions.
* `ret` returns from a function.
* Local variables can be stored in the stack frame.
* `if` and `switch` become comparisons and jumps.
* Strings are placed in `.rodata`.
* `printf()` and `add()` appear as function calls, but their final addresses are not resolved yet.
* `@PLT` is related to later linking/dynamic linking.
* Each `.c` file is compiled independently into its own `.s` file.

---

# At This Stage: What I Know

✓ `.c` → `.i` → `.s`

✓ `.s` contains assembly instructions

✓ C variables can become registers or stack locations

✓ Function arguments are passed using registers

✓ Return values use `%eax`

✓ `call` calls another function

✓ `ret` returns from a function

✓ `if`/`switch` become comparisons and jumps

✓ `add.c` produces code for `add()`

✓ `main.c` contains calls to `add()`, `sub()`, `mul()`, `divide()`, `printf()`, and `scanf()`

---

# At This Stage: What I Do NOT Know

✗ How assembly becomes machine-code bytes

✗ What exactly is inside the `.o` file

✗ Where symbols such as `add` are stored

✗ What relocations are

✗ How `main.o` refers to `add()`

✗ How the linker connects `main.o` with `add.o`

✗ How `printf()` is finally connected to libc

✗ How PLT/GOT work internally

These are the questions for the **object-file stage and linking stages**.

---

# Conclusion

The `.s` stage shows the first major transition from **programming language concepts to CPU-level concepts**.

```text
C
 ↓
Preprocessed C (.i)
 ↓
Assembly (.s)
 ↓
Object file (.o)
 ↓
Linking
 ↓
Executable
```

The most important things to understand here are:

```text
Registers
   ↓
Instructions
   ↓
Stack
   ↓
Calling convention
   ↓
Function calls
   ↓
Branches
```

The next stage is `.o`, where this assembly becomes **machine-code bytes plus symbols and relocation information**.
