# Experiment 6 — Static Library (`.a`)

## Goal

Understand what a static library is and how `.o` files are packaged into a `.a` archive.

---

## 1. Create the Static Library

The library was created with:

```bash
ar rcs build/libcalc.a \
    build/objects/add.o \
    build/objects/sub.o \
    build/objects/mul.o \
    build/objects/div.o
```

The resulting file was about 5.2 KB:

```text
-rw-rw-r-- 1 avatar avatar 5.2K ... build/libcalc.a
```

---

## 2. Identify the File

```bash
file build/libcalc.a
```

Output:

```text
build/libcalc.a: current ar archive
```

Important observation:

> A `.a` static library is an **archive**, not an ELF executable.

The `ar` tool is used to create and inspect this archive format.

---

## 3. Inspect Archive Contents

```bash
ar t build/libcalc.a
```

Output:

```text
add.o
sub.o
mul.o
div.o
```

The library contains the four object files.

Conceptually:

```text
libcalc.a
├── add.o
├── sub.o
├── mul.o
└── div.o
```

The object files remain separate inside the archive.

---

## 4. Inspect Symbols

```bash
nm build/libcalc.a
```

Important output:

```text
add.o:
0000000000000000 T add

sub.o:
0000000000000000 T sub

mul.o:
0000000000000000 T mul

div.o:
0000000000000000 T divide
```

`T` means the symbol is **defined in the `.text` section**.

Therefore the library provides these functions:

```text
add
sub
mul
divide
```

---

## 5. What a Static Library Actually Is

A static library is essentially a collection of relocatable object files:

```text
add.o
sub.o
mul.o
div.o
   │
   │ ar
   ▼
libcalc.a
```

It is **not** one combined executable.

The linker later examines the archive and extracts the object files it needs.

For example, if `main.o` references:

```text
add
sub
```

the linker can take the corresponding object files from `libcalc.a`.

Conceptually:

```text
main.o
  │
  │ references add, sub
  ▼
libcalc.a
  ├── add.o    ← needed
  ├── sub.o    ← needed
  ├── mul.o    ← possibly unused
  └── div.o    ← possibly unused
```

This selection behavior is an important difference between a static library and simply passing every `.o` file directly to the linker.

---

## 6. Connection to Previous Experiments

Previously:

```text
add.c
  │ compiler
  ▼
add.o
```

Now:

```text
add.o
sub.o
mul.o
div.o
   │
   │ ar
   ▼
libcalc.a
```

The complete pipeline is becoming:

```text
.c
 │
 │ compiler
 ▼
.o
 │
 │ ar
 ▼
.a
 │
 │ linker
 ▼
ELF executable
 │
 │ loader
 ▼
process memory
```

---

## Key Takeaways

* `.a` is a **static library archive**.
* `ar` creates and manages the archive.
* `ar t` lists the object files stored inside it.
* The archive contains separate `.o` files rather than one combined executable.
* `nm` can inspect symbols inside the archive.
* `T` means a symbol is defined in `.text`.
* `libcalc.a` provides `add`, `sub`, `mul`, and `divide`.
* The linker can extract required object files from a static library during static linking.
* Static libraries participate in linking **before runtime**; their selected object code becomes part of the final executable.
