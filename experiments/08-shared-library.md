# Experiment 8 — Shared Library (`.so`)

## Goal

Build the calculator functions as a shared library and observe how a `.so` differs from a static `.a` library.

---

## 1. Build Position-Independent Object Files

The calculator source files were compiled using:

```bash
gcc -fPIC -c c/src/add.c -I c/inc -o build/objects/add-pic.o
gcc -fPIC -c c/src/sub.c -I c/inc -o build/objects/sub-pic.o
gcc -fPIC -c c/src/mul.c -I c/inc -o build/objects/mul-pic.o
gcc -fPIC -c c/src/div.c -I c/inc -o build/objects/div-pic.o
```

`file` identified them as:

```text
ELF 64-bit LSB relocatable, x86-64
```

So `-fPIC` does **not** directly produce a shared library.

It produces relocatable object files containing **position-independent code**.

---

## 2. Create the Shared Library

The first attempt failed because the shell line continuations were written incorrectly.

The successful command was:

```bash
gcc -shared build/objects/add-pic.o \
    build/objects/sub-pic.o \
    build/objects/mul-pic.o \
    build/objects/div-pic.o \
    -o build/libcalc.so
```

The resulting file was identified as:

```text
build/libcalc.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, ... not stripped
```

Therefore:

> A shared library is itself an ELF file.

---

## 3. ELF Type

```bash
readelf -h build/libcalc.so
```

Important fields:

```text
Type:              DYN (Shared object file)
Entry point:       0x0
Program headers:   11
Section headers:   25
```

The `DYN` type is also used for PIE executables, but the context is different:

```text
PIE executable
    DYN + executable entry point

Shared library
    DYN + normally no executable entry point
```

The shared library has an entry point of `0x0`.

It is intended to be loaded and used by another program rather than started directly as the main program.

---

## 4. Dynamic Symbols

```bash
nm -D build/libcalc.so
```

Important output:

```text
00000000000010f9 T add
000000000000113e T divide
0000000000001127 T mul
0000000000001111 T sub
```

The `T` indicates that these functions are defined in executable `.text` code.

The `-D` option is important:

> `nm -D` displays the **dynamic symbol table**.

The shared library therefore exposes these functions as dynamic symbols that another dynamically linked object can resolve.

Conceptually:

```text
libcalc.so
│
├── add
├── sub
├── mul
└── divide
```

These functions remain inside the separate `.so` file.

---

## 5. Important Shared-Library Sections

The shared library contains:

```text
.dynsym
.dynstr
.rela.dyn

.text
.plt
.plt.got

.got
.got.plt

.data
.bss
```

Several of these are familiar from the executable inspected earlier.

### `.dynsym`

Dynamic symbol table.

It contains symbols needed by the dynamic-linking system.

### `.dynstr`

Strings associated with dynamic linking, such as symbol names.

### `.rela.dyn`

Dynamic relocation records.

These allow addresses and references to be adjusted when the shared object is loaded.

### `.plt`

Procedure Linkage Table.

It provides code stubs used for dynamically resolved function calls.

### `.got`

Global Offset Table.

It stores addresses used by position-independent/dynamically linked code.

These will become much clearer when we link `main` against `libcalc.so`.

---

## 6. `.a` vs `.so`

The two libraries have fundamentally different roles.

### Static library

```text
libcalc.a
│
├── add.o
├── sub.o
├── mul.o
└── div.o
```

The linker extracts required object files and places their code into the executable.

```text
libcalc.a
     │
     │ linker
     ▼
executable
```

### Shared library

```text
libcalc.so
│
├── add
├── sub
├── mul
└── divide
```

The library remains a separate ELF file.

```text
executable ───────► libcalc.so
       dynamic linking
```

The dynamic linker/loader can resolve the required symbols when the program starts or when libraries are loaded.

---

## 7. Why `-fPIC`?

`-fPIC` means **Position-Independent Code**.

A shared library may be loaded at different virtual addresses in different processes.

Therefore, its code should avoid depending on fixed absolute addresses wherever possible.

Conceptually:

```text
Without PIC:

code ──► fixed address assumption

With PIC:

code ──► position-independent reference
             │
             ▼
        can work at different load addresses
```

This is particularly important for shared libraries and is closely related to mechanisms such as the GOT and PLT.

---

## Key Takeaways

* `.so` is a shared library stored as an **ELF shared object**.
* `-fPIC` produces position-independent relocatable object files.
* `-shared` combines those objects into a shared library.
* `libcalc.so` has ELF type `DYN`.
* Unlike the main executable, its entry point is `0x0`.
* `nm -D` shows dynamically exported symbols.
* `add`, `sub`, `mul`, and `divide` are exported from the shared library.
* A static `.a` library is an archive of `.o` files.
* A `.so` is a complete ELF shared object with its own sections, program headers, dynamic symbols, and relocation information.
* The `.so` remains a separate file rather than having its functions copied directly into the main executable.
* `-fPIC` is used so shared-library code can operate correctly regardless of where the library is loaded.
* `.dynsym`, `.rela.dyn`, `.plt`, and `.got` are important parts of the dynamic-linking mechanism.
