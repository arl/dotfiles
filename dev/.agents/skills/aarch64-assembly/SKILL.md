---
name: aarch64-assembly
description: Use when reading, writing, or debugging AArch64 assembly.
version: 1.0.0
author: hermione
license: CC-BY-4.0
metadata:
  hermes:
    tags: [assembly, arm64, aarch64, low-level, syscalls, abi]
    related_skills: [sega-mega-drive-vdp-hardware]
---

# AArch64 (ARM64) Assembly

Practical AArch64 assembly for Linux and macOS (Apple Silicon). Examples below were verified by
assemble-and-run on native aarch64 (gcc / GNU as). The package is 64-bit only; A32/Thumb live on
different targets and are out of scope here.

## When to use this
- Reading or writing `.s` / assembly for arm64 hosts (Oracle Linux arm64, Apple Silicon, AWS Graviton, RPi4/5 in 64-bit mode).
- Writing inline asm or hand-tuned hot loops in C.
- Debugging what the compiler generated (`gcc -S`, `objdump -d`).
- Understanding AAPCS64 (function-call ABI) for interop between asm and C.

## Compile / run quick reference (Linux, GNU as)
- Assemble only: `gcc -c foo.s -o foo.o`
- Static, no libc, `_start` entry: `gcc -nostdlib -static -o prog foo.s` (or `ld -o prog foo.o`)
- Link against libc / link an asm function into a C program: `gcc -o prog main.c foo.s`
- Disassemble: `aarch64-linux-gnu-objdump -d prog` (or plain `objdump -d`)
- Compiler asm for comparison: `gcc -O2 -S prog.c`

On macOS (Apple Silicon / clang) the assembler syntax is essentially identical; link with
`gcc -o prog main.c foo.s` and use the Mach-O `_` prefix on symbols and default `ld` as the linker.

## Registers
31 general-purpose registers, x0–x30 (always 64-bit; `w0`–`w30` alias the low 32 bits). Plus:
- `sp` — stack pointer. xzr/wzr — the always-zero register (reads as zero, writes discarded).
- `xzr`/`wzr` are encoded as register 31; `sp` shares encoding 31 in some contexts (loads/addressing).
- x29 = frame pointer (FP), x30 = link register (LR) holding the `ret` return address.
- SIMD/FP: v0–v31 (128-bit), d0–d31 (fp64), s0–s31 (fp32), h0/b0 (fp16/int8).
- No flags register — conditions are produced by separate `cmp`/`tst` and consumed by conditional instructions.

### AAPCS64 calling convention (important)
- Integer args x0–x7, FP/SIMD args v0–v7; returns in x0 (or w0) / v0.
- **Callee-saved (must preserve):** x19–x28, fp(x29), lr(x30), sp, and d8–d15 (bottom 64 bits), v8–v15.
- **Caller-saved (scratch, may clobber):** x0–x18, and v0–v7, v16–v31.
- `x8` is the indirect-result register (return-struct pointer) — treat as caller-saved scratch.
- Stack must stay 16-byte aligned; sp must be 16-byte aligned before a `bl` and at any `svc`.
- Local stack usage is the caller's responsibility; the callee allocates its own frame with `stp x29,x30,[sp,#-N]!`.

## Instructions you'll actually use
- ALU: `add`, `sub`, `and`, `orr`, `eor`, `mul`, `madd x0,x1,x2,x3` (= x1*x2+x3), `udiv`/`sdiv`.
- Shift as an option: `add x0, x1, x2, lsl #3`, `lsr`, `asr`, `ror`, `lsl` — can suffix many ALU ops.
- Loads/stores: `ldr`/`str`; scaled addressing `ldr x0,[x1,#8]`, pre/post-index `[x1,#16]!`, `[x1],#16`.
- Pairs: `ldp`/`stp` — load/store two regs, ideal for frames and spilling.
- Branches: `b` (uncond), `bl` (call, sets lr), `ret`, `cbz/cbnz` (compare+brnch), `tbz/tbnz` (bit test), and conditional `b.cond`.
- Compare + conditional: `cmp x0,x1` then `b.eq/b.ne/b.lt/b.ge/b.gt/b.le/b.lo/b.hs/b.eq`... (suffixes: eq ne hs lo hi ls ge lt gt le al nv; mi/pl, vs/vc).
- Condition select without branching: `csel x0,x1,x2,eq`, `csinc`, `cset`.
- Types/unions (load-store width): `ldrb`,`strb` (byte), `ldrh`,`strh` (half), `ldr`,`str` (word/dword by reg width), `ldrsw` (sign-extend word->dword), `ldrsh`,`ldrsb`.
- Bit ops: `clz`, `rbit`, `rev16/32/64`, `bic` (and-not), `orn`, `eon`.
- Misc: `svc #0` (syscall), `nop`, `mrs`/`msr` (system regs), `dc`/`ic` (cache), `dmb`/`dsb`/`isb` (barriers), `eret` (exception return).

## Immediates (a classic gotcha)
- Most ALU immediates are not full 64-bit. A single `mov x0,#imm` only works for values encodable in
  16 bits (with optional shift to 16/32/48/63) or certain bitmask patterns.
- General 3-instruction idiom for an arbitrary 64-bit constant:
  ```
  mov x0, #0x3            // low 16 bits
  movk x0, #0x0, lsl #16
  movk x0, #0x100, lsl #32    // bits 32..47
  movk x0, #0x0, lsl #48
  ```
  `movk` keeps the other bits, `movz` zeroes everything else, `movn` sets them.
- **Literal pool:** `ldr x0, =some_label_or_number` makes the assembler emit a nearby 64-bit constant
  (an `adrp`+`ldr`), which is the easiest way to get an arbitrary address/number. Inside a
  `_start`-style program, `.rodata` + `ldr x0,=msg` is the idiomatic way to load a string address.

## Linear memory loads in syscall code
In hand-written `_start` code (non-PIE), `ldr x1, =msg` works. In PIE/shared contexts use
`adrp x0, msg` then `add x0, x0, :lo12:msg`, or just let the C compiler/linker sort it out by
`gcc -no-pie`.

## Stack frame pattern (non-leaf function)
Push callee-saved + FP + LR together, use the frame, and restore in one instruction (verified):
```
stp x29, x30, [sp, #-32]!   // allocate 32 bytes, save FP and LR (pre-index)
mov x29, sp                 // FP = SP (unwind marker)
str x19, [sp, #16]          // we clobber x19, must preserve it
...
ldr x19, [sp, #16]          // restore x19
ldp x29, x30, [sp], #32     // restore FP/LR and deallocate (post-index)
ret
```
Least-significant bits of the return address are handled by hardware; `ret` reads x30.

## Linux syscalls (no libc)
- `mov x8, #<number>` then `svc #0`. Return/errno in x0.
- Common numbers (arm64): write=64, read=63, openat=56, close=57, exit=93, exit_group=94, mmap=222,
  brk=214, getpid=172, execve=221. (Linux arm64 syscall numbers differ from x86_64 — never reuse them.)
- Write then exit:
```
mov x0, #1      // fd = stdout
ldr x1, =msg
ldr x2, =msg_end
sub x2, x2, x1  // len
mov x8, #64     // write
svc #0
mov x0, #0
mov x8, #93     // exit
svc #0
```
- Handle errors: on `svc` return, x0 is negative (`-errno`) on failure; leave it as-is and let the
  kernel print/return it, or branch to an exit path with that value.

## Pitfalls
- **Callee-saved regs:** clobber x19–x28, d8–d15 without saving → subtle corruption. Use x0–x18 (and
  v0–v7) for scratch only.
- **Immediate range:** `mov x0,#1000000` fails to assemble. Use `movz/movk` or `ldr =`.
- **sp alignment:** sp must be 16-byte aligned at a `bl`/`svc`; ever-changing frame sizes are a bug.
- **w vs x width:** `add w0,w1,w2` is a 32-bit add that zero-extends; mixing widths silently changes semantics.
- **PIE addresses:** in PIE, RIP relative address forms differ; prefer `gcc -no-pie` for simple `_start` demos or use `adrp`+`:lo12:`.
- **End warning "end of file not at end of a line" is harmless** (just a trailing-line warning); ensure the `.s` file ends with a newline to silence it.
- **xzr vs sp encoding:** in some instructions sp and xzr share encoding 31; you can't read `sp` as a normal value — copy to another reg first.
- **No flags register:** each compare must be immediately consumed by an `b.cond`/`csel`/`ccmp` since nothing is sticky.

## Verify native tooling available
On this box (aarch64 Linux): `gcc`, `as`, `aarch64-linux-gnu-*` are present natively — `gcc -o t main.c foo.s` assembles, links, and runs locally. Use `uname -m` to confirm the host is aarch64 first; if building for a different target, use the `aarch64-linux-gnu-` cross tools or `aarch64-apple-darwin` clang.