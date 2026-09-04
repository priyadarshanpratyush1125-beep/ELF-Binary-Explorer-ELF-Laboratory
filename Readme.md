# ELF Binary Explorer

A hands-on learning project to understand what happens to a C program during **compilation, linking, and runtime loading**.

This is **not a calculator project**. The calculator is only a small example program used to make the compiler and ELF concepts easier to observe.

The main goal is to inspect what the tools produce at each stage and understand how the pieces are connected.

## What I am Learning

The project follows the C program through these stages:

* `.c` — original C source code
* `.i` — preprocessed C source
* `.s` — generated assembly
* `.o` — ELF relocatable object file
* `.a` — static library
* `.so` — shared library
* executable — final ELF program
* runtime loading — how shared libraries are found and loaded

I also inspect ELF internals such as:

* sections
* symbols
* relocations
* segments
* dynamic dependencies
* PLT/GOT
* dynamic linking

The `pipeline_inspection/` directory contains the early experiments where I directly inspected the contents of the `.c`, `.i`, and `.s` files.

## Project Requirement

The project requires a Linux environment with an x86-64 GCC toolchain.

The exact compiler and system details may vary, so the purpose is to **observe the output on the current system**, not to memorize one exact output.

## Prerequisites

Basic knowledge of:

* C programming
* functions and header files
* compiling a C program with GCC
* basic Linux terminal commands

Helpful but not required:

* basic assembly knowledge
* basic understanding of processes and memory
* basic Git knowledge

## Tools Used

The experiments mainly use:

* `gcc` — compilation and linking
* `ar` — creating static libraries
* `file` — identifying file types
* `nm` — inspecting symbols
* `readelf` — inspecting ELF structures
* `objdump` — inspecting machine code and relocations
* `ldd` — viewing shared-library dependencies
* standard Linux shell commands

## Repository Structure

```text
ELF-Binary-Explorer/
├── c/
│   ├── src/          # C source files
│   └── inc/          # Header files
│
├── pipeline_inspection/
│   └── ...            # Early .c, .i and .s inspection
│
├── build/
│   ├── objects/       # Object files
│   └── ...            # Libraries created during experiments
│
├── binaries/          # Executables created during experiments
│
└── experiments/       # Short learning notes for each experiment
```

The exact files may grow as new experiments are added.

## Learning Path

The experiments are intentionally incremental.

I first inspect the source and generated files, then move into ELF object files, symbols and relocations, followed by static libraries, static linking, shared libraries and dynamic linking.

Each experiment is based on **actual command output from my system**.

The notes focus on the important concepts learned from that output instead of trying to document every ELF field or compiler option.

## Goal

By the end of this project, I should be able to explain:

> How does a simple C source file become an executable, and what happens when that executable runs?

The purpose is understanding the **C → ELF → linker → loader** pipeline through experimentation.
