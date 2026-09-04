# Experiment 4 — Inspecting ELF Relocations

## Objective

Understand how an ELF object file records references that cannot be completely resolved until the linking stage.

---

## Commands Used

```bash id="b0x9h2"
readelf -r build/objects/main.o
readelf -r build/objects/add.o
objdump -r build/objects/main.o
```

---

## 1. What Is Relocation?

An object file contains machine code, but some addresses cannot be finalized while compiling an individual source file.

For example, `main.o` calls:

```text id="d8f6q3"
add
sub
mul
divide
printf
puts
__isoc23_scanf
```

The compiler cannot know the final runtime address of all these symbols at the object-file stage.

Therefore, the object file contains **relocation entries**.

The linker later uses these entries to fix the required locations.

Conceptually:

```text id="j3u7b9"
Object File
    │
    ├── machine code
    ├── symbols
    └── relocation information
              │
              ↓
           Linker
              │
              ↓
     final addresses/references
```

---

## 2. `.rela.text`

`main.o` contains:

```text id="x8j4p1"
Relocation section '.rela.text'
contains 35 entries
```

This relocation section is associated with `.text`.

The `.text` section contains machine instructions, and some of those instructions contain references that need to be fixed later.

---

## 3. Example: Relocation for `add`

One important entry is:

```text id="d0yq7v"
000000000121  R_X86_64_PLT32  add - 4
```

This means that there is a reference to `add` at an offset inside `.text`.

The important parts are:

```text id="w2j9pf"
Offset: 0x121
Type:   R_X86_64_PLT32
Symbol: add
Addend: -4
```

The linker uses this information when producing the final linked program.

This connects directly to the assembly seen earlier:

```text id="3i8m1d"
call add@PLT
```

---

## 4. Other Project Functions

The relocation table contains similar entries for the other calculator functions:

```text id="0xqj5r"
R_X86_64_PLT32  add
R_X86_64_PLT32  sub
R_X86_64_PLT32  mul
R_X86_64_PLT32  divide
```

Therefore:

```text id="c8k5f1"
main.o
 │
 ├── relocation → add
 ├── relocation → sub
 ├── relocation → mul
 └── relocation → divide
```

The linker will later connect these references with the definitions found in:

```text id="j8d6s2"
add.o
sub.o
mul.o
div.o
```

---

## 5. Library Function Relocations

`main.o` also contains relocations for:

```text id="k7m4sa"
printf
puts
__isoc23_scanf
__stack_chk_fail
```

For example:

```text id="2x7f1k"
R_X86_64_PLT32  printf - 4
```

These references will be handled during the later linking process.

The exact runtime behavior of library calls and the PLT/GOT will be studied during the dynamic-linking experiments.

For now, the important idea is:

```text id="1f6p8z"
main.o
   ↓
references external functions
   ↓
relocation entries
   ↓
linker
```

---

## 6. `.rodata` Relocations

The relocation table also contains entries such as:

```text id="g9y2kc"
R_X86_64_PC32 .rodata - 4
R_X86_64_PC32 .rodata + 24
R_X86_64_PC32 .rodata + 46
```

These references point from machine code in `.text` to data stored in `.rodata`.

This makes sense because `main.c` contains many strings:

```text id="w3x8g1"
"C Compilation Pipeline Calculator"
"1. Addition"
"2. Subtraction"
"3. Multiplication"
"4. Division"
"Result: %d"
"Invalid choice!"
```

So relocation is not only about functions.

It can also be required when machine code references data whose final location is not yet fixed.

---

## 7. Important Relocation Fields

A relocation entry looks like:

```text id="c2j6mz"
Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000000121    ...            R_X86_64_PLT32  ...           add - 4
```

The most important fields for me are:

### Offset

The location inside the associated section where the relocation must be applied.

Example:

```text id="m0f7c2"
0x121
```

means the relevant location is at offset `0x121` in `.text`.

### Type

Example:

```text id="1b4k8n"
R_X86_64_PLT32
```

The relocation type tells the linker what kind of relocation is required.

Another type in my output is:

```text id="a7n3w5"
R_X86_64_PC32
```

For now, I mainly need to recognize these types rather than memorize their exact formulas.

### Symbol

Examples:

```text id="k2x6v9"
add
sub
mul
divide
printf
puts
```

The symbol identifies what the relocation refers to.

### Addend

Examples:

```text id="y6z1qa"
-4
+24
+46
+a8
```

The addend is an additional value used when calculating the final relocated value.

---

## 8. `objdump -r` Gives a Compact View

`objdump -r` displays the relocation records in a shorter format:

```text id="q0p4vk"
RELOCATION RECORDS FOR [.text]:

OFFSET           TYPE              VALUE
0000000000000121 R_X86_64_PLT32   add-0x0000000000000004
000000000000014d R_X86_64_PLT32   sub-0x0000000000000004
0000000000000176 R_X86_64_PLT32   mul-0x0000000000000004
000000000000019f R_X86_64_PLT32   divide-0x0000000000000004
```

This is useful when I want a quick view of relocation records.

`readelf -r` provides more detailed ELF-oriented information.

---

## 9. Why `add.o` Has No `.rela.text`

The relocation output for `add.o` is:

```text id="s4f1kc"
Relocation section '.rela.eh_frame'
contains 1 entry
```

There is no `.rela.text` relocation.

This makes sense because `add()`:

```c id="w8g2m4"
int add(int a, int b)
{
    return a + b;
}
```

does not call another external function or reference external data.

Its `.text` contains self-contained arithmetic instructions.

It still has a relocation for `.eh_frame`, which is metadata used for unwinding.

That is not the main focus of this experiment.

---

## 10. Symbols + Relocations

The previous experiment showed:

```text id="v5x3ja"
main.o

T main
U add
U sub
U mul
U divide
```

This experiment shows:

```text id="d3q7bn"
.rela.text

relocation → add
relocation → sub
relocation → mul
relocation → divide
```

These two concepts work together.

```text id="x6m1vp"
Symbol Table
    │
    │ tells us about symbols
    ↓
Relocation Table
    │
    │ tells linker where/how references must be fixed
    ↓
Linker
```

---

## 11. Complete Picture So Far

The ELF object file can now be understood as:

```text id="v8s2mc"
main.o
│
├── ELF Header
│
├── .text
│     └── machine code
│
├── .rodata
│     └── string literals
│
├── .rela.text
│     └── relocation records
│
├── .symtab
│     └── symbol information
│
└── .strtab
      └── symbol names
```

The linker takes information from these structures and combines object files into a final executable.

---

## Key Understanding

The most important idea from this experiment is:

```text id="b7q4pn"
Machine Code
     +
Unresolved References
     ↓
Relocation Entries
     ↓
Linker
     ↓
Fixed References in Final Linked Program
```

For example:

```text id="e4w9cz"
main.o
  │
  ├── U add
  │     +
  │   relocation for add
  │
  ↓
linker
  │
  ↓
add.o
  │
  └── T add
```

Therefore, **symbol information tells the linker what a symbol is, while relocation information tells the linker where/how a reference needs to be fixed.**

---

## What I Learned

* Object files can contain references whose final addresses are not known yet.
* Relocation information records these references for the linker.
* `readelf -r` displays relocation entries.
* `objdump -r` provides a compact relocation view.
* `.rela.text` contains relocation records associated with `.text`.
* `R_X86_64_PLT32` appears for many function-call references in my object file.
* `R_X86_64_PC32` appears for references such as `.rodata`.
* Important relocation fields are offset, type, symbol, and addend.
* `main.o` contains relocations for `add`, `sub`, `mul`, `divide`, `printf`, `puts`, and `scanf`.
* `add.o` has no `.rela.text` because its function does not reference external functions or data.
* Symbols and relocations work together during linking.

---

## At This Stage

I now understand:

```text id="n7w4q2"
Source
  ↓
Assembly
  ↓
Object File
  ├── Sections
  ├── Machine Code
  ├── Symbols
  └── Relocations
          ↓
        Linker
```

The next major concept is the difference between:

```text id="r5c8y1"
Sections
    vs
Segments
```

Sections are mainly important to the linker and binary structure, while segments describe how parts of the final executable are arranged for loading into memory.

### Next Experiment

**Experiment 5 — Sections vs Program Segments**
