# Experiment 09 — Dynamic Linking

## Goal

Understand how an executable uses a shared library (`.so`) at runtime instead of copying its code into the executable.

## Build

Linked `main.o` against the previously created shared library:

```bash
gcc build/objects/main.o \
    -Lbuild \
    -lcalc \
    -o binaries/calculator-dynamic
```

## 1. Executable type

```bash
file binaries/calculator-dynamic
```

Output identified it as:

```text
ELF 64-bit LSB pie executable, x86-64, dynamically linked,
interpreter /lib64/ld-linux-x86-64.so.2
```

This is a PIE executable and uses the dynamic loader.

Unlike the static-library experiment, the calculator functions are not copied into this executable.

## 2. Runtime dependency

```bash
ldd binaries/calculator-dynamic
```

Important result:

```text
libcalc.so => not found
libc.so.6 => /usr/lib/x86_64-linux-gnu/libc.so.6
/lib64/ld-linux-x86-64.so.2
```

The executable knows it needs `libcalc.so`, but the runtime loader cannot find it because `build/` is not in its library search path.

The program therefore fails when run normally:

```text
error while loading shared libraries: libcalc.so:
cannot open shared object file: No such file or directory
```

This demonstrates an important distinction:

```text
-Lbuild
```

helps the **linker** find the library during the build.

It does not automatically make `build/` a runtime library search directory.

For this project, the executable can be run with:

```bash
LD_LIBRARY_PATH=build ./binaries/calculator-dynamic
```

## 3. `NEEDED` entries

```bash
readelf -d binaries/calculator-dynamic | grep NEEDED
```

Result:

```text
Shared library: [libcalc.so]
Shared library: [libc.so.6]
```

`NEEDED` entries record shared libraries required by the executable.

The executable therefore contains a dependency on `libcalc.so` rather than containing its implementation directly.

## 4. Undefined dynamic symbols

```bash
nm -D binaries/calculator-dynamic | grep -E ' (add|sub|mul|divide)$'
```

Result:

```text
                 U add
                 U divide
                 U mul
                 U sub
```

`U` means **undefined in this executable**.

The functions are expected to be provided by another loaded object, in this case `libcalc.so`.

This is different from the static executable, where:

```text
T add
T sub
T mul
T divide
```

appeared because the implementations from `libcalc.a` were incorporated into the executable.

## 5. Dynamic relocations

```bash
readelf -r binaries/calculator-dynamic
```

The `.rela.plt` section contains entries such as:

```text
R_X86_64_JUMP_SLOT ... add
R_X86_64_JUMP_SLOT ... divide
R_X86_64_JUMP_SLOT ... mul
R_X86_64_JUMP_SLOT ... sub
```

These relocations are associated with dynamically linked function calls.

The executable also contains `.rela.dyn` for other dynamic relocations.

## 6. PLT call path

```bash
objdump -d binaries/calculator-dynamic
```

shows calls such as:

```text
call   10c0 <add@plt>
call   1130 <sub@plt>
call   1120 <mul@plt>
call   10e0 <divide@plt>
```

The PLT entries perform indirect jumps through GOT locations:

```text
add@plt
    ↓
GOT entry
    ↓
resolved address of add()
    ↓
libcalc.so
```

So the executable does not directly call a fixed address inside `libcalc.so`.

## 7. Important concepts

### Static vs dynamic linking

```text
Static library:

main.o ──► libcalc.a ──► calculator-static
                         contains add/sub/mul/divide


Shared library:

main.o ──► calculator-dynamic
                  │
                  └──► libcalc.so
```

### Link time vs runtime

```text
-Lbuild -lcalc
       │
       ▼
linker finds libcalc.so
       │
       ▼
executable records NEEDED: libcalc.so
       │
       ▼
program starts
       │
       ▼
dynamic loader searches for libcalc.so
```

### Key takeaway

A shared library remains a separate ELF object.

The executable records its dependency through `DT_NEEDED`, keeps dynamic references to its functions, and uses mechanisms such as:

* `.dynsym`
* `.dynstr`
* `.rela.plt`
* `.plt`
* `.got`

to connect those references to the shared library at runtime.
