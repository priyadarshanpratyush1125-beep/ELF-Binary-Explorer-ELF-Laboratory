# Experiment 3 — Inspecting ELF Symbols

## Objective

Understand how symbols are represented inside an ELF object file and how symbols connect different object files during linking.

---

## Commands Used

```bash
readelf -s build/objects/main.o
nm build/objects/main.o

readelf -s build/objects/add.o
nm build/objects/add.o
```

---

## 1. Symbol Table

`readelf -s` shows the ELF symbol table:

```text
Symbol table '.symtab'
```

The symbol table contains information about functions and other symbols.

For `main.o`, important entries include:

```text
main
puts
printf
__isoc23_scanf
add
sub
mul
divide
__stack_chk_fail
```

---

## 2. Defined vs Undefined Symbols

The most important observation is that `main.o` contains both defined and undefined symbols.

From `nm`:

```text
0000000000000000 T main

                 U add
                 U divide
                 U __isoc23_scanf
                 U mul
                 U printf
                 U puts
                 U __stack_chk_fail
                 U sub
```

`main` is defined inside `main.o`.

The other functions are referenced by `main.o`, but are not defined there.

---

## 3. `T` — Symbol Defined in `.text`

`nm` shows:

```text
0000000000000000 T main
```

`T` means the symbol is defined in the `.text` section.

The `readelf` output confirms this:

```text
main
Size = 487
Ndx = 1
```

Section `1` is:

```text
.text
```

Therefore:

```text
main.o
   │
   └── .text
         └── main()
```

The machine code for `main()` is inside the `.text` section.

---

## 4. `U` — Undefined Symbol

`nm` shows:

```text
U add
U sub
U mul
U divide
U printf
U puts
U __isoc23_scanf
```

`U` means **Undefined**.

This does not mean the function does not exist.

It means that this particular object file does not contain its definition.

For example:

```text
main.o
   │
   └── U add
```

means:

> `main.o` needs a definition of `add` from somewhere else.

---

## 5. `add.o` Defines `add`

The symbol table of `add.o` contains:

```text
3: 0000000000000000    24 FUNC    GLOBAL DEFAULT    1 add
```

And `nm` shows:

```text
0000000000000000 T add
```

Therefore:

```text
main.o                  add.o
------                  -----
U add   ───────────────→ T add
```

This is the basic idea behind symbol resolution during linking.

---

## 6. Connecting All Calculator Functions

The project contains multiple object files.

The symbol relationships can be viewed conceptually as:

```text
                 main.o
                   │
        ┌──────────┼──────────┐
        │          │          │
      U add      U sub      U mul
        │          │          │
        ↓          ↓          ↓
      add.o      sub.o      mul.o
        │          │          │
      T add      T sub      T mul

                   │
                U divide
                   │
                   ↓
                 div.o
                   │
                 T divide
```

So `main.o` contains references to functions defined in other object files.

---

## 7. Library Functions

`main.o` also contains undefined symbols such as:

```text
U printf
U puts
U __isoc23_scanf
U __stack_chk_fail
```

These functions are not defined inside `main.o`.

They are supplied by other libraries/runtime components during the later linking process.

This explains why compiling a source file into an object file does not yet produce a complete executable.

---

## 8. `readelf -s` Gives More Information Than `nm`

`nm` gives a compact symbol view:

```text
T main
U add
U printf
```

`readelf -s` provides more details:

```text
Num
Value
Size
Type
Bind
Vis
Ndx
Name
```

For example:

```text
4: 0000000000000000   487 FUNC GLOBAL DEFAULT 1 main
```

Important fields:

* `Value` → symbol value/address within the object at this stage
* `Size` → size of the symbol
* `Type` → `FUNC` means function
* `Bind` → `GLOBAL` means globally visible symbol
* `Ndx` → section index where the symbol is defined
* `Name` → symbol name

For undefined symbols:

```text
8: 0000000000000000     0 NOTYPE GLOBAL DEFAULT UND add
```

`UND` means **undefined**.

---

## 9. Why Undefined Symbols Are Important

At the object-file stage, the final addresses of functions are not known.

For example:

```text
main.o
   |
   | needs add
   ↓
linker
   |
   | finds definition
   ↓
add.o
```

The linker will eventually combine the object files and resolve these symbol references.

Therefore:

```text
Symbol table
     ↓
helps linker understand
who defines what
and who needs what
```

---

## 10. Important Observation About `puts`

The source code contains many `printf` calls.

However, the symbol table also contains:

```text
U puts
```

The compiler may optimize some simple `printf` calls into `puts`.

Therefore, the symbol table of the generated object file is not necessarily a one-to-one copy of the function names written in the source code.

The generated object file is the actual result of compilation.

---

## Key Understanding

The most important concept from this experiment is:

```text
Defined symbol
    ↓
T
    ↓
This object provides the symbol


Undefined symbol
    ↓
U
    ↓
This object needs the symbol from somewhere else
```

For this project:

```text
main.o
├── T main
├── U add
├── U sub
├── U mul
├── U divide
├── U printf
├── U puts
└── U __isoc23_scanf

add.o
└── T add
```

---

## Connection to Linking

The symbol information allows the linker to connect object files:

```text
main.o
   │
   ├── U add ───────→ add.o ─── T add
   ├── U sub ───────→ sub.o ─── T sub
   ├── U mul ───────→ mul.o ─── T mul
   └── U divide ────→ div.o ─── T divide
```

This is one of the fundamental jobs of the linker.

---

## What I Learned

* ELF object files contain symbol tables.
* `readelf -s` provides detailed symbol information.
* `nm` provides a compact symbol view.
* `T` means a symbol is defined in `.text`.
* `U` means a symbol is undefined in that object file.
* `main.o` defines `main`.
* `main.o` references `add`, `sub`, `mul`, and `divide`.
* `add.o` defines `add`.
* Undefined symbols are important because the linker must resolve them later.
* Library functions can also appear as undefined symbols in an object file.
* Symbol resolution is a key part of the linking process.

---

## At This Stage

I understand the relationship:

```text
Source
  ↓
Assembly
  ↓
Object file
  ├── Sections
  ├── Machine code
  ├── Symbols
  └── Relocation information
        ↓
      Linker
```

### Next Experiment

**Experiment 4 — Inspecting Relocations**

The next experiment will show exactly how references such as:

```text
add
printf
sub
mul
divide
```

are recorded for the linker to fix later.

Planned command:

```bash
readelf -r build/objects/main.o
```
