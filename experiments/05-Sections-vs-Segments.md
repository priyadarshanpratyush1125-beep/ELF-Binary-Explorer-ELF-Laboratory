# Experiment 5 — Sections vs Segments

## Goal

Understand the difference between **ELF sections** and **ELF segments**, and why a final executable contains both.

---

## Commands

```bash
readelf -S binaries/calculator
readelf -l binaries/calculator
objdump -h binaries/calculator
```

---

## 1. Sections

`readelf -S` shows the ELF **section headers**.

Important sections in this executable:

| Section     | Purpose                                                 |
| ----------- | ------------------------------------------------------- |
| `.text`     | Machine code                                            |
| `.rodata`   | Read-only data and string literals                      |
| `.data`     | Initialized writable data                               |
| `.bss`      | Zero/uninitialized writable storage                     |
| `.plt`      | Procedure Linkage Table used for dynamic function calls |
| `.got`      | Global Offset Table used for dynamic address resolution |
| `.dynsym`   | Dynamic symbol table                                    |
| `.rela.dyn` | Dynamic relocation records                              |
| `.rela.plt` | Relocations associated with PLT entries                 |

Sections provide a **logical organization** of the contents of the ELF file.

They are especially important to the compiler, linker, debugger, and binary-analysis tools.

---

## 2. Segments

`readelf -l` shows the ELF **program headers**.

Unlike sections, program headers describe how the executable should be loaded into memory.

The important segments are the `LOAD` segments:

```text
LOAD    R
LOAD    R E
LOAD    R
LOAD    RW
```

These correspond roughly to different memory permissions:

```text
R      → readable
R E    → readable + executable
RW     → readable + writable
```

The loader uses this information when mapping the executable into the process's address space.

---

## 3. Section → Segment Mapping

The most useful part of the output was:

```text
Section to Segment mapping:

03  .init .plt .plt.got .plt.sec .text .fini
04  .rodata .eh_frame_hdr .eh_frame ...
05  .init_array .fini_array .dynamic .got .data .bss
```

This shows that multiple sections can be grouped into one runtime segment.

For example:

```text
Sections                         Segment
------------------------------------------------
.init
.plt
.plt.got
.plt.sec
.text
.fini                         →  LOAD R E

.rodata
.eh_frame_hdr
.eh_frame                     →  LOAD R

.init_array
.fini_array
.dynamic
.got
.data
.bss                          →  LOAD RW
```

So:

> **Sections describe logical organization; segments describe runtime loading.**

---

## 4. Why `.bss` Is Special

The executable contains:

```text
.bss    NOBITS
```

The `.bss` section has memory size but does not contain the corresponding zero bytes in the file.

This can also be seen in the writable `LOAD` segment:

```text
FileSiz  = 0x270
MemSiz   = 0x278
```

The difference represents memory that must exist when the program runs but does not need to be stored in the executable.

This is why `.bss` can save file space.

---

## 5. `.o` vs Executable

Earlier, the object files had:

```text
Type: REL (Relocatable file)

Program headers: 0
```

The final executable has:

```text
Type: DYN (Position-Independent Executable file)

Program headers: 14
```

This is a major transition:

```text
.o file
  │
  ├── sections
  ├── symbols
  └── relocations
       │
       │ linker
       ▼
ELF executable
  │
  ├── sections
  └── program headers / segments
          │
          │ loader
          ▼
     process memory
```

The relocatable object is primarily an input to the linker.

The final executable additionally contains the information needed by the loader to construct the process's memory image.

---

## 6. Entry Point Observation

`readelf -l` reports:

```text
Entry point 0x10c0
```

`0x10c0` is the beginning of the `.text` section in this executable.

However, this does **not** mean that execution begins directly at `main()`.

For a normal dynamically linked Linux executable, startup code runs first and eventually calls `main()`.

We'll inspect that startup path later.

---

## Key Takeaways

* **Sections** organize ELF contents logically.
* **Segments** describe how parts of the ELF should be loaded into memory.
* The linker creates the final section and segment layout.
* The loader primarily uses **program headers/segments**, not section headers, to load the executable.
* Multiple sections can belong to one segment.
* `R`, `R E`, and `RW` segments correspond to different memory permissions.
* `.bss` occupies memory but does not store its zero-filled contents in the file.
* `.o` files can have sections without program headers.
* A final executable has program headers describing its runtime memory layout.
* `main()` is not necessarily the ELF entry point.
