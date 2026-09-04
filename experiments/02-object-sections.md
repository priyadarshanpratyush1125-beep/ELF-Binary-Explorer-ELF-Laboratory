# Experiment 2 — Inspecting ELF Sections

## Objective

Understand how an ELF relocatable object file (`.o`) is divided into different sections and what each important section contains.

---

## Commands Used

```bash
readelf -S build/objects/main.o
objdump -h build/objects/main.o
readelf -S build/objects/add.o
objdump -h build/objects/add.o
```

---

## 1. Object Files Are Divided Into Sections

The output of `readelf -S` shows that `main.o` contains **14 section headers**.

Important sections include:

```text
.text
.rela.text
.data
.bss
.rodata
.symtab
.strtab
```

Different sections store different kinds of information.

---

## 2. `.text` — Machine Code

```text
[ 1] .text
      Type: PROGBITS
      Flags: AX
```

The `.text` section contains the machine-code instructions generated from the C source.

For `main.o`:

```text
Size = 0x1e7
```

For `add.o`:

```text
Size = 0x18
```

This matches what I saw earlier in the assembly stage.

For example, `add.c`:

```c
int add(int a, int b)
{
    return a + b;
}
```

is compiled into machine instructions stored inside the `.text` section of `add.o`.

Important flags:

* `A` = Allocated in memory
* `X` = Executable

So `.text` is essentially:

```text
.text → executable machine code
```

---

## 3. `.rodata` — Read-Only Data

`main.o` contains:

```text
[ 5] .rodata
      Size = 0xc8
      Flags = A
```

`.rodata` contains read-only data.

In my program, this includes strings such as:

```text
"C Compilation Pipeline Calculator"
"1. Addition"
"2. Subtraction"
"Result: %d"
"Invalid choice!"
```

These strings appeared earlier in the assembly output as `.LC0`, `.LC1`, etc.

Therefore:

```text
C string literals
      ↓
.rodata
```

The arithmetic object files such as `add.o` do not need `.rodata` because they do not contain string literals.

---

## 4. `.data` — Initialized Writable Data

My object files contain a `.data` section:

```text
.data
Size = 0
Flags = WA
```

`.data` is used for initialized global or static variables that require writable storage.

Example:

```c
int global = 10;
```

would normally require writable initialized data and could be placed in `.data`.

My current program does not have such global/static data, so the `.data` section has size `0`.

---

## 5. `.bss` — Uninitialized/Zero-Initialized Data

My object files also contain:

```text
.bss
Size = 0
Flags = WA
```

`.bss` is used for uninitialized or zero-initialized global/static variables.

For example:

```c
int counter;
```

could be stored in `.bss`.

My current source code does not contain global/static variables requiring `.bss`, so its size is `0`.

An important property is that `.bss` has type:

```text
NOBITS
```

This means it represents memory needed at runtime but does not need actual initialized bytes stored in the object file.

---

## 6. `.rela.text` — Relocation Information

`main.o` contains:

```text
.rela.text
Type: RELA
```

This section is associated with `.text`.

It contains relocation entries that tell the linker how certain references inside the machine code need to be fixed later.

This is important because `main.c` calls functions such as:

```c
printf(...)
scanf(...)
add(...)
sub(...)
mul(...)
divide(...)
```

At the object-file stage, final addresses are not yet known.

Therefore:

```text
main.o
  ↓
.text contains machine code
  ↓
.rela.text contains information for references
  ↓
linker fixes addresses later
```

This will be studied in much more detail in the **relocation experiment**.

---

## 7. `.symtab` — Symbol Table

The object files contain:

```text
.symtab
Type: SYMTAB
```

The symbol table stores information about symbols in the object file.

Examples of symbols include:

```text
main
add
printf
scanf
```

depending on which object file is being examined.

The symbol table is important to the linker because it helps connect definitions and references between object files.

For example:

```text
main.o
    references add
          ↓
      linker
          ↓
add.o
    defines add
```

The linker uses symbol information to resolve these relationships.

The symbol table will be studied more deeply in the next ELF experiment.

---

## 8. `.strtab` — String Table

The object file also contains:

```text
.strtab
Type: STRTAB
```

This section stores strings used by the ELF symbol table, such as symbol names.

Conceptually:

```text
.symtab
   ↓
symbol information

.strtab
   ↓
symbol names
```

I do not need to study the internal format of these tables yet. The important point is that ELF uses them to represent symbols and their names.

---

## 9. Other Sections

My object files also contain sections such as:

```text
.comment
.note.GNU-stack
.note.gnu.property
.eh_frame
.shstrtab
```

These contain compiler metadata, stack-related metadata, unwind information, or ELF section-name information.

I will not focus on these yet because they are not central to understanding the basic compilation and linking process.

---

## 10. Important Difference Between `main.o` and `add.o`

`main.o` contains:

```text
.text
.rodata
.rela.text
.symtab
.strtab
...
```

because `main.c` contains both machine code and many string literals, as well as references that require relocation.

`add.o` contains:

```text
.text
.symtab
.strtab
...
```

but does not contain `.rodata`.

This makes sense because `add.c` only contains arithmetic code:

```c
int add(int a, int b)
{
    return a + b;
}
```

There are no string literals.

---

## 11. Connection With the Assembly Stage

Previously I inspected:

```text
main.s
```

and saw:

```text
.text
.rodata
main:
    ...
```

After assembling:

```text
main.s
    ↓
main.o
```

the information is organized into ELF sections:

```text
main.o
├── .text       → machine code
├── .rodata     → read-only strings
├── .rela.text  → relocation information
├── .symtab     → symbol information
└── .strtab     → symbol names
```

So the `.o` file is not simply "machine code".

It is an ELF container holding machine code **plus the information needed by later linking stages**.

---

## Key Understanding

The most important sections for me at this stage are:

```text
.text       → machine code
.rodata     → read-only data / strings
.data       → initialized writable data
.bss        → uninitialized/zero-initialized data
.rela.*     → relocation information
.symtab     → symbols
.strtab     → symbol names
```

The most important concept is:

```text
Source Code
     ↓
Assembly
     ↓
Object File
     ↓
┌───────────────────────┐
│ ELF Object File       │
│                       │
│ .text    → code       │
│ .rodata  → strings    │
│ .data    → data       │
│ .bss     → storage    │
│ .rela.*  → relocation │
│ .symtab  → symbols    │
│ .strtab  → names      │
└───────────────────────┘
     ↓
Linker
```

---

## What I Learned

* An `.o` file is organized into ELF sections.
* `.text` contains machine code.
* `.rodata` contains read-only data such as string literals.
* `.data` contains initialized writable data.
* `.bss` represents uninitialized/zero-initialized data.
* Relocation sections contain information needed by the linker to fix references later.
* `.symtab` contains symbol information.
* `.strtab` contains symbol names.
* Different source files produce object files with different sections depending on what the source contains.
* The linker works with these sections and the information associated with them.

---

## At This Stage

I now understand:

```text
.s  → assembly instructions
.o  → ELF relocatable object containing sections
```

I also understand that the object file contains more than just machine code.

### Next Experiment

**Experiment 3 — Inspecting ELF Symbols**

I will use tools such as:

```bash
readelf -s build/objects/main.o
nm build/objects/main.o
```

to understand how symbols such as `main`, `add`, `printf`, and other references are represented inside an ELF object file.
