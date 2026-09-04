# Experiment 7 — Static Linking

## Goal

Observe what happens when a static library is linked into an executable.

The important distinction is:

> **Statically linking a library does not necessarily mean the entire executable is statically linked.**

---

## 1. Link Against `libcalc.a`

The executable was created with:

```bash
gcc build/objects/main.o \
    -Lbuild \
    -lcalc \
    -o binaries/calculator-static
```

This tells the linker to search `build/` for `libcalc.a` and use it during linking.

---

## 2. Inspect the Result

```bash
file binaries/calculator-static
```

Output:

```text
ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV),
dynamically linked,
interpreter /lib64/ld-linux-x86-64.so.2,
...
not stripped
```

Important observation:

The executable is still **dynamically linked**.

Why?

Because the command linked `libcalc.a` statically, but did not request static linking of the system libraries such as libc.

---

## 3. Our Functions Are Inside the Executable

```bash
nm binaries/calculator-static | grep -E ' (add|sub|mul|divide)$'
```

Output:

```text
0000000000001390 T add
00000000000013d5 T divide
00000000000013be T mul
00000000000013a8 T sub
```

All four functions are now defined inside the final executable.

Compare this with the earlier object files:

```text
add.o      → T add
sub.o      → T sub
mul.o      → T mul
div.o      → T divide
```

The linker has taken the required object code from `libcalc.a` and incorporated it into the executable.

Conceptually:

```text
libcalc.a
├── add.o
├── sub.o
├── mul.o
└── div.o
       │
       │ linker extracts required objects
       ▼
calculator-static
├── main
├── add
├── sub
├── mul
└── divide
```

---

## 4. `main` Is Also Defined

```bash
nm binaries/calculator-static | grep ' main$'
```

Output:

```text
00000000000011a9 T main
```

So the executable contains both the application's `main` function and the functions brought in from the static library.

---

## 5. Check Dynamic Dependencies

```bash
ldd binaries/calculator-static
```

Output includes:

```text
linux-vdso.so.1
libc.so.6
/lib64/ld-linux-x86-64.so.2
```

Therefore the executable still depends on the system's shared libc.

Compare:

```text
calculator-static
    └── libcalc.a → linked into executable
    └── libc.so.6 → dynamically linked

calculator
    └── libc.so.6 → dynamically linked
```

The name `calculator-static` therefore means:

> **Our calculator library was statically linked, not that the whole executable is fully static.**

---

## 6. Runtime Behavior

Both executables were run with choice `1`.

Both produced:

```text
Result: 25
```

So from the user's perspective, the programs behave identically.

The difference is how their code and dependencies were assembled.

---

## 7. Static Library vs Shared Library

This experiment gives us an important distinction.

### Static library

```text
libcalc.a
   │
   │ linker
   ▼
calculator
```

The required object code from the archive becomes part of the executable.

### Shared library

```text
libcalc.so
   │
   │ executable references it
   ▼
calculator
   │
   │ loader at runtime
   ▼
libcalc.so
```

The shared library remains a separate file and is loaded/resolved at runtime.

We'll investigate this next.

---

## Key Takeaways

* `libcalc.a` is a static archive of `.o` files.
* When linked, the linker can extract required object files from the archive.
* `add`, `sub`, `mul`, and `divide` became defined symbols in the executable.
* `nm` confirms those functions are now part of the executable.
* `ldd` shows that libc is still dynamically linked.
* Therefore, **static linking one library ≠ fully static linking the entire program**.
* A fully static executable would require static versions of the system libraries as well.
* The next major comparison is a **shared library (`.so`)**, where the library stays separate from the executable and is involved in runtime dynamic linking.
