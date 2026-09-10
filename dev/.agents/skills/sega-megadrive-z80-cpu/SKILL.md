---
name: z80-cpu
description: Use when implementing/debugging a Z80 CPU core.
version: 1.0
author: Hermes Agent
license: CC BY — full sources bundled as references/
metadata:
  hermes:
    tags: [z80, zpu, genesis, megadrive, sound, ym2612, sn76489, emulation]
    related_skills: [sega-mega-drive-vdp-hardware]
---

# Zilog Z80 / Mega Drive "ZPU" — implementation reference

The Z80 is a binary-compatible superset of the Intel 8080: same base register
file and instruction set, plus index registers IX/IY, an alternate register
set (AF'/BC'/DE'/HL'), the interrupt vector register I and DRAM refresh
register R, block-transfer/search instructions (LDI/LDDR/CPI/CPIR/INIR/
OTDR...), and bit manipulation (BIT/SET/RES). It is what your emulator's
"ZPU" register stub should eventually become.

Use this skill when you implement a Z80 core or wire up the Mega Drive's Z80
subsystem. The companion `sega-mega-drive-vdp-hardware` skill covers the
shared bus, YM2612/PSG, DMA and the 68k side of bus arbitration — read both
when you touch the bus.

## When to Use
- Writing the Z80 CPU core (interpreted fetch/execute, registers, flags,
  instruction timing).
- Adding the MD's Z80 co-processor: the 8KB RAM, YM2612/PSG access, bank
  switching, and the 68k↔Z80 control registers.
- Debugging sound-driver init, VBlank interrupts, or "Z80 won't start" bugs.

## How to use
- The **core CPU facts** (registers, flags, timing model, interrupts) are
  distilled here from the bundled **Zilog Z80 Programmer's Reference**.
- The **Mega Drive integration** (memory map, bank register, $A11100/$A11200)
  is from the bundled SegaRetro / Railgun wiki / Plutiedev / BreakIntoProgram
  pages.
- Every source is saved locally under `references/` — open them for exact
  per-instruction opcode encodings, opcode timing tables, and full prose.
- All clock frequencies are stated for NTSC (53.693175 MHz master). HAL (PAL)
  = 53.203424 MHz.

---

## 1. Clock & scheduler integration (Mega Drive)

The Z80 is NOT on the master clock like the 68k/VDP — it has its own divider:

- **Z80 clock = master ÷ 15** ≈ **3.579545 MHz** (NTSC) / 3.546894 MHz (PAL).
  Your frequency `Subsystem` scheduler should advance the Z80 at ÷15 (same
  pattern as the 68k's ÷7 and VDP/VM2612's ÷7).
- Z80 and 68k run **asynchronously** on the MD; they synchronize only through
  the shared bus (bank window + YM/PSG) and the control registers. When the
  Z80 touches ROM (the bank window) the arbiter pauses the 68k; when the 68k
  touches Z80 RAM it must first halt the Z80 via bus request.

### Placing it in the emulator
Model it as a Subsystem that owns: the Z80 register file, the 8KB RAM, its
view of the memory map, and thread-safe handles to (a) the 68k ROM via the
bank window and (b) the YM2612/SN76489 (physically on the Z80 bus). Expose:
- `Reset()` / set the /RESET line
- `/BUSREQ` grant/release
- `INT` line (VBlank)
- a `Step()`/tick that advances one T-state or instruction

---

## 2. Registers

```
  AF   BC   DE   HL      SP          PC
  AF'  BC'  DE'  HL'     (alternate set, EXX / EX AF,AF')
  IX   IY                (16-bit index registers)
  I    R                 (interrupt vector base, DRAM refresh)
```
- 8-bit halves are addressable: A, F, B, C, D, E, H, L.
- **AF'/BC'/DE'/HL'** are a full second register file toggled via `EX AF,AF'`
  (opcode 08) and `EXX` (D9). They let an interrupt handler swap in a scratch
  context. Do NOT lose them — `EXX` is constant on real sound drivers.
- **I** (interrupt vector base, 8-bit) and **R** (refresh). R is a **7-bit**
  counter that increments once per **M1 (opcode fetch)**; **bit 7 of R is
  preserved separately** — its value comes from `LD R,A` and is not part of the
  count. Model as `R = (R & 0x80) | ((R + 1) & 0x7F)` after each M1. Sampling
  hardware believes R wraps at 7 bits only.

### Flags (F register), bits 7→0: `S Z X H X P/V N C`
- **S** (7): sign = result bit 7.
- **Z** (6): zero.
- **X** (5) and **X** (3): undocumented copies of result bits 5 and 3 on most
  8-bit ALU ops. Real software and some validation suites read them — set
  them correctly rather than zeroing.
- **H** (4): half-carry (carry out of bit 3) — BCD, consumed by DAA.
- **P/V** (2): **parity** (1 = even) for logical ops (AND/OR/XOR), **overflow**
  (two's-complement) for arithmetic (ADD/SUB/INC/DEC), `BC≠0` after the block
  transfer/search ops (block ends when P/V=0), and the **IFF2 mask bit** after
  `LD A,I` / `LD A,R`.
- **N** (1): subtract flag, set by SUB/SBC/CP/... , consumed by DAA.
- **C** (0): carry out of bit 7; also the shifted-out bit for rotates/shifts.

### Undocumented / 8080-alias notes that affect execution
- **DD/FD-prefixed opcodes that target H or L actually access IXH/IXL** (the
  index register's high/low byte) — e.g. `DD 6C` = `LD L,IXL`, `DD 65` =
  `LD H,IXH`. A naive core that routes these to H/L is wrong.
- **Do not trap undocumented opcodes.** The real Z80 executes them (they were
  never "illegal"). Boilerplate behavior: the undocumented `SLL/SL1` (CB-prefix
  opcode `30`), the `NEG` aliases (`ED 44/4C/54/5C/64/6C/74/7C` are all NEG),
  `LD A,(C)`/`LD (C),A` style ops, `IN F,(C)`, `RP/RRD`, `IM 0/1/2` duplicates,
  `JP (IX)`, `EX (SP),IX`. Executing a reasonable approximation is far better
  than trapping.
- `BIT b,(HL)`: result flag set as documented, but the OPERAND VALUE is
  re-read from the same location (flags S/P/V reflect the byte) — a subtle but
  testable behavioral difference.
- `DAA` operates on the A register using the N and H flags plus C (the classic
  NOR tune of carry adjustments). Implement the documented 8-bit algorithm
  feeding from H/C/N — do not half-implement it with only C.

---

## 3. Instruction set & timing model

The Z80 has (with prefixes, four "instructions spaces"): the base set, the
**CB** (bit/rotate/shift) extension, the **ED** (block, I/O, 16-bit) extension,
and the **DD/FD** (index) extensions. Prefixed instructions are single
instructions whose opcode is 2 (or more) bytes. An opcode prefixed DD/FD that
uses `(IX+d)`/`(IY+d)` adds a signed displacement `d`; **on such instructions
the Z80 does dummy reads of memory at PC and at (IX−1)/(IX+1) to fill the
pipeline** — relevant only if you model the bus pedantically.

### Timing (T-states / machine cycles) — matters for a cycle-accurate core
- Time is counted in **T (clock) cycles**; instructions are a sequence of
  **M (machine) cycles**.
- The first machine cycle of any instruction is **M1 = opcode fetch**, which
  is **4, 5, or 6 T-cycles**. A plain register-register op (e.g. `LD A,B`,
  `NOP`) = **1 M1 cycle, 4 T-states total**.
- Non-fetch M-cycles (memory read/write, I/O) run **3–5 T-states** each.
- `WAIT` can lengthen any T-state (stretch an M-cycle). MD base accesses do
  not add Z80 wait states except via bus-request contention.
- **M1 also drives DRAM refresh**: during the last T-states of M1, the `RFSH`
  line is active and the 7-bit refresh address is on the ADDRESS bus. R is
  incremented here.

### Representative timings to anchor your tables
| Instruction                  | M-cycles | T-states |
|------------------------------|----------|----------|
| NOP / LD A,r / INC r (8-bit) | 1        | 4        |
| ADD A, (HL)                  | 2        | 7        |
| LD (nn),A                    | 3 (M1,M2,M3) | 13  |
| JP / JR / CALL (not taken)   | 3 / 2 / 3 | 10 / 12  |
| LDIR / CPIR (per iteration)  | 5        | 21 (repeat) |
| BIT b,(HL)                   | 2        | 12       |
| HALT                         | 1        | 4 (per state) |

Do not hand-derive timing — the bundled PDF's instruction-set table has the
exact M/T counts for every legal opcode (and the common undocumented aliases).
Use it as the source of truth when you generate opcode timing tables.

---

## 4. Interrupts & special control instructions

- **IM 0 / 1 / 2** select the interrupt mode.
  - IM 0: device puts an instruction on the bus.
  - IM 1: always vectored to **RST 38h** (address 0x0038).
  - IM 2: 8-bit vector from the device; the **I** register is the high byte →
    jump to `(I:vector)`. On the MD the data bus is $FF → long vector table
    at `I:$FF`.
- **INT** (maskable) is latched by the **IFF1** flip-flop; honoring it requires
  **EI**. **IFF2** mirrors IFF1 (used to restore state after NMI via `LD A,I` →
  P/V = IFF2).
- **NMI** is **always** recognized at the end of the current machine cycle
  (never masked; mode is irrelevant — it vectors to address **0x0066**).
- `DI` and `EI` set/clear IFF1*. **EI does not take effect until the
  instruction AFTER it** — an interrupt arriving immediately after `EI` is
  deferred by one instruction. Same for `IM n`.
- **HALT**: the CPU stops fetching, executing NOPs and driving M1 for refresh;
  it resumes on /INT, /NMI, or /RESET handling. Model a `halted` flag: when
  set, tick M1 refresh-only until an interrupt (unmasked) or reset deasserts
  it. Missing this state makes sound drivers with `HALT`-wait loops spin wrong.
- Interrupt pushing: on an acknowledged interrupt the Z80 pushes **PC** onto
  the stack via SP (M1 = a special "interrupt acknowledge" M1 for IM2), then
  sets PC. Order: keep SP behavior exact (push high then low byte).
- `RST p` (00/08/10/18/20/28/30/38) pushes PC and jumps to p — same stack op
  as an interrupt.

> **Mega Drive specifically:** the Z80 generally runs in **IM 1** and the INT
> line is pulsed on **VBlank**, so its driver hits the handler at **0x0038**.
> Music tied to this runs at the refresh rate (slightly slower on PAL = the
> classic "50 Hz syndrome"), which is why mature drivers instead poll the
> YM2612 timers.

---

## 5. Mega Drive memory map (Z80's own 64K address space)

| Z80 addr   | Contents                                              | Notes                              |
|------------|-------------------------------------------------------|------------------------------------|
| $0000-$1FFF| **8 KB Z80 RAM** (SRAM/PSRAM)                          | this is $A00000 in 68k space       |
| $2000-$3FFF| Reserved (decodes to nothing / open bus)              | typically ignored                  |
| $4000-$4001| **YM2612** port A (`A0`, `D0`)                         | FM channel select / data           |
| $4002-$4003| **YM2612** port B (`A1`, `D1`)                         | FM channel select / data           |
| $4004-$5FFF| Reserved                                               |                                    |
| $6000      | **Bank register** (write-only, bit-serial)             | pick the 32KB ROM bank @ $8000     |
| $6001-$7F10| Reserved                                               |                                    |
| $7F11      | **SN76489 PSG** register                               | (address line A0 decoded)          |
| $7F12-$7FFF| Reserved                                               |                                    |
| $8000-$FFFF| **32 KB banked window into 68k memory** (ROM)          | defaults to $000000 ($0000 region) |

- The Z80 sees **its own address space**, not the 68k's. The 8KB RAM is shared:
  68k sees it at **$A00000–$A01FFF** (byte access only).
- YM2612 and the PSG live on the **Z80 bus** — this is why the 68k must pause
  the Z80 to reach the FM chip, and why sound drivers run "for free" without
  68k involvement.

### Bank register ($6000) — bit-serial 68k→Z80 addressing
Writing to $6000 selects which 32 KB of the 24-bit 68k address space appears
at Z80 $8000–$FFFF. The **9 most-significant address bits (bits 15–23)** are
clocked in **one bit at a time into bit 0 of the register window**, starting
with **bit 15 first and ending with bit 23**. So one full bankswitch = **9
writes** to $6000, each carrying one bit (LSB-first in the 15→23 order).

Example paging in $800000 ⇒ top-9-bits `1_0000_0000` ⇒ write  8×0 then 1×1:
```
Z80_PAGE_REG equ 0x6000
        xor a
        ld  (Z80_PAGE_REG),a   ; bit15=0
        ... repeat 7 more times (bits 16..22 = 0)
        inc a
        ld  (Z80_PAGE_REG),a   ; bit23=1
```
- **Bank switching is slow** — on real hardware, ~**100+ cycles per write**,
  so drivers avoid it (keep tune + samples in one bank). Don't make it free in
  the emulator, but for correctness only the target address matters.
- Bank value **$00** maps $8000 to $000000. The window must point at a run of
  32 KB of real 68k memory (ROM by convention).

---

## 6. 68k ↔ Z80 control registers (Mega Drive)

These are 16-bit registers in the 68k's own space near the VDP. Access them
as **words** (the meaningful control bits sit at bit 8 of the written value).

### $A11200 — Z80_RESET (/RESET latch)
- Write **$0100** → deassert **/RESET** → Z80 **runs** (from reset vector $0000).
- Write **$0000** → assert **/RESET low** → Z80 held in reset (all registers
  zeroed, PC=0, IFF1/IFF2=0).
- Program-loading sequence === *request bus → assert reset → copy → deassert
  reset → release bus* so the freshly-loaded program starts from $0000.
- A held/reset state should also clear the subset to a sane initial condition
  when the bus is subsequently granted (see §7).

### $A11100 — Z80_BUS_REQ (/BUSREQ request + status)
- Write **$0100** → request the Z80 bus (request /BUSREQ). The Z80, on reaching
  a safe point (end of the current machine cycle), relinquishes the bus.
- Write **$0000** → release /BUSREQ, Z80 resumes.
- **Read back bit 0**: `0` = **bus granted / Z80 stopped** (68k may access Z80
  memory), `1` = Z80 still owns the bus (keep waiting). The canonical wait loop
  branches while bit 0 is set:
  ```
  move.w #$100,($A11100)     ; request
  .lw: btst.b #0,($A11100)   ; bit0 set => not granted yet
        bne.s .lw
  ```
- Only when there is a pending bus request may the 68k safely touch Z80 RAM or
  YM2612/PSG (they are on the Z80 bus). Release does NOT require waiting.

### Loading a program (canonical, both CPUs agree)
```
move.w #$100,($A11200)   ; assert /RESET (hold)
move.w #$100,($A11100)   ; request bus
.w:  btst.b #0,($A11100) ; wait until granted (bit0=0)
     bne.s .w
; copy Z80 program into $A00000.. (byte copies ONLY)
move.b (a0)+,(a1)+       ; ... loop ...
move.w #$0000,($A11200)  ; deassert /RESET  (Z80 ready to run)
move.w #$0000,($A11100)  ; release bus      (Z80 starts at $0000)
```
> On most MDs you can also leave /RESET deasserted during the copy and rely
> on /BUSREQ alone to hold the Z80. Emulate the strict form above; it is the
> one every driver tolerates.

### 68k ↔ Z80 communication
- Only channel is **shared Z80 RAM** ($A00000, byte-accessed) watched by the
  running Z80 program. 68k always: pause Z80 → poke bytes → resume.
- Typical scheme: a **mailbox** or a small **circular command queue** (a head
  pointer owned by 68k, a tail pointer owned by the Z80 driver). Keep the
  traffic low — pausing the Z80 per command slows the music driver and corrupts
  timing/artefacts.
- ⚠️ A 68k bus request can land **mid-instruction**: the Z80 may have completed
  only half of a 16-bit memory op when it grants the bus. The atomic unit on
  the Z80 is **one byte**. Either tolerate that, or (in the emulator) only
  grant /BUSREQ at an instruction boundary.

---

## 7. Reset, /BUSREQ, NMI, INT cycle behavior (core)

- **/RESET (active low):** sets the IFF1/IFF2 both 0, clears I/R/PC to 0 (and
  the register file to a defined state), forces IM 0. The MD uses the latch in
  §6 to generate this edge. While asserted, the Z80 does nothing.
- **/BUSREQ:** sampled each clock; when active, at the end of the **current
  machine cycle** the CPU places ADDR/DATA/MREQ/RD/WR in high-impedance, then
  asserts /BUSACK. It resumes when /BUSREQ deasserts. Model "bus granted =
  not stepping the Z80, bus tri-stated".
- **/INT:** sampled at the end of an M-cycle (if EI and IFF1 set). Acknowledge
  cycle pushes PC. With no IM2 devices, MD wiring = IM1 → 0x0038.
- **HALT** stays in M1 refresh (driving the bus) until INT/NMI/RESET.

---

## 8. Mega Drive sound-driver role (why the Z80 exists)

The Z80 is the MD's sound co-processor. It runs the sound driver autonomously:
- Two classic pure-Z80 drivers: **SMPS/Z80** (Sonic 3) and **GEMS** (Sonic
  Spinball); plus homebrew drivers (e.g. Echo).
- It writes the **YM2612** (FM) and **SN76489** (PSG) directly — the 68k
  typically only pauses it to load a song (bank switch) or queue commands.
- DAC/PCM playback is often done by the 68k on later titles; the Z80 carries
  the FM/PSG sequencing either way.
- The driver code lives in the **8 KB Z80 RAM**; samples/data live in a **32 KB
  ROM bank** reached through $6000. Because driver code is in RAM, self
  modifying code is common (speed).

### Sound-timing gotchas for the emulator
- YM2612 register-address writes must be spaced (see the VDP/VM2612 skill) —
  on the Z80 that's roughly one FM write per ~33.6 Z80 cycles; don't let the
  Z80 blast FM ports at full rate if you care about fidelity.
- VBlank INT (IM1) gives "steady" music but varies PAL vs NTSC (50 Hz
  syndrome); many drivers poll YM2612 timer B for frame pacing instead.
- If music tempo or DAC timing looks off, check (a) Z80 clock ÷15, (b) bus
  arbitration pauses on ROM/YM access, (c) VBlank INT polarity, (d) bank
  switch cost.

---

## 9. Gotcha checklist
1. Z80 clock = **master ÷ 15** (≈3.58 MHz); runs async to the 68k.
2. **DD/FD-prefixed H/L ops are really IXH/IXL**; don't route to H/L.
3. **Don't trap undocumented opcodes** — execute a sensible alias.
4. Set the **X (5,3) and H flags**; P/V semantics vary per instruction family.
5. R is a **7-bit** refresh counter with **bit 7 preserved**; increments per M1.
6. **EI/IM take effect one instruction later**; HALT must keep refreshing until
   an enabled interrupt or reset.
7. YM2612 + PSG are on the **Z80 bus**.
8. Bank register needs **9 bit-serial writes**; costs ~100 cycles each.
9. 68k↔Z80 comms go through shared RAM **byte-only**, after a bus-request wait
   loop on $A11100 bit 0.
10. $A11200/$A11100 polarity: **$100 = run/release**, **$000 = reset/hold**;
    read bit0 of $A11100: **0 = granted**.

---

## References (bundled locally in this skill)

All sources are saved under `references/` in this skill directory. Open the
relevant one for exact detail — don't regenerate from memory.

- `references/Zilog_Z80_Programmers_Reference.pdf` — the Zilog Z80 User's
  Manual (UM008005-0205), 308pp. **Authoritative** for the full instruction
  set, opcode encodings, per-opcode M/T timing tables, flag effects, interrupt
  modes, NMI/halt/reset cycles and the register diagram.
- `references/z80_prog_ref.txt` — full text-layer extraction of that PDF (for
  grep-able searching without opening the PDF).
- `references/railgun-Zilog-Z80.txt` — MD wiki: the **MD-specific memory map**,
  control registers, bank register, driver init asm and sound-driver guidance.
- `references/plutiedev-Using-the-Z80.txt` — concise 68k-side tutorial: loading
  a program, pause/resume macros, YM2612 access, DMA interaction.
- `references/segaretro-Z80.txt` — background/history; Intel-8080 heritage, the
  architectural extensions, uses across Sega systems.
- `references/bip-MD-z80-co-processor.txt` — BreakIntoProgram music-driver
  write-up: clock speed, bank paging code, mailbox/circular-queue inter-CPU
  comm, and the PauseZ80/freeZ80 patterns with working asm.