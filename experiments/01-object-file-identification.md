# Experiment 1 — Object File Identification

## Objective

Understand what a `.o` file actually is.

The current pipeline is:

```text
.c
 ↓
.i
 ↓
.s
 ↓
.o
 ↓
linker
 ↓
executable
```

---

## Commands

```bash
file build/objects/main.o
```

```bash
readelf -h build/objects/main.o
```

```bash
objdump -f build/objects/main.o
```

---

## Important Observations

### 1. `.o` is an ELF file

Output:

```text
ELF 64-bit LSB relocatable, x86-64
```

Therefore:

```text
.o = ELF relocatable object file
```

It is already an ELF file, but it is **not a complete executable**.

---

### 2. It is ELF64

```text
Class: ELF64
```

The object file targets a 64-bit ELF environment.

---

### 3. It is little-endian

```text
Data: 2's complement, little endian
```

The target architecture uses little-endian byte ordering.

---

### 4. The file type is relocatable

```text
Type: REL (Relocatable file)
```

This is the most important observation.

The object file is designed to be processed by the linker:

```text
main.o ──┐
add.o  ──┤
sub.o  ──┤
mul.o  ──┤
div.o  ──┘
          ↓
       linker
          ↓
     executable
```

---

### 5. No final entry point yet

```text
Entry point address: 0x0
```

A relocatable object file does not have a meaningful runtime entry point.

The final executable will have an entry point after linking.

---

### 6. No program headers

```text
Number of program headers: 0
```

This means the `.o` file is not yet a loadable program.

Program headers become important when studying the final executable and the Linux loader.

---

### 7. Symbols and relocations exist

`objdump` reports:

```text
flags 0x00000011:
HAS_RELOC, HAS_SYMS
```

This confirms that the object file contains:

```text
symbols
+
relocation information
```

We will inspect these separately in later experiments.

---

## Key Understanding

An object file is more than machine code.

Conceptually:

```text
             main.o
        ┌───────────────┐
        │ ELF header    │
        │ machine code  │
        │ sections      │
        │ symbols       │
        │ relocations   │
        └───────────────┘
```

The linker uses this information to create the final executable.

---

## What I Learned

* `.o` files are ELF files.
* My `.o` files are ELF64.
* They target x86-64.
* They use little-endian representation.
* `.o` files are **relocatable**, not executables.
* A relocatable object does not have a final entry point.
* `.o` files contain information about symbols and relocations.
* Program headers are not present in my relocatable `.o` files.
* The linker will combine these object files into the final executable.

---

## At This Stage: What I Know

✓ `.c → .i → .s → .o`

✓ `.o` is an ELF relocatable object file

✓ `.o` contains machine code

✓ `.o` contains sections

✓ `.o` contains symbols

✓ `.o` contains relocation information

✓ `.o` is not directly a complete executable

✓ The linker is the next major step

---

## At This Stage: What I Do NOT Know

✗ What sections are actually inside `main.o`

✗ Where the machine code is stored

✗ What symbols `main.o` contains

✗ Why `main.o` has undefined symbols such as `add`

✗ What relocation entries look like

✗ How the linker resolves those relocations

These will be investigated in the next experiments.

---

## Conclusion

The `.o` file is the first ELF object in my pipeline.

```text
C source
   ↓
preprocessed C
   ↓
assembly
   ↓
ELF relocatable object
   ↓
linker
   ↓
ELF executable
```

The most important idea from this experiment is:

> **A `.o` file contains machine code plus the information required by the linker to create the final executable.**

Next: **Experiment 2 — Inspecting ELF Sections.**
