---
name: sega-mega-drive-vdp-hardware
description: Use when developing a Sega Genesis/Mega Drive emulator.
version: 1.0
author: Hermes Agent (distilled from Kabuto's notes, v1.5)
license: CC BY — full verbatim source bundled as references/kabuto-full.txt
metadata:
  hermes:
    tags: [sega, genesis, megadrive, vdp, ym2612, emulation]
    related_skills: []
---

# Sega Mega Drive / Genesis — hardware implementation reference

Distilled from **Kabuto's Mega Drive hardware notes v1.5** (the "Overdrive 2"
document). These are the undocumented / subtle behaviors that cause real
emulator/frame bugs: bus arbitration, VDP pipeline phases, DMA + FIFO semantics,
shadow/highlight, and the gotchas authors fix "for no obvious reason".

The **full verbatim** source (all obscure sections incl. the debug register,
plane-masking AND bugs, 128k mode, Mode 4 glitches) is in
`references/kabuto-full.txt`. Use this SKILL.md for day-to-day implementation;
open the reference when you need exact bit-level or exotic behavior.

- All timings are in **master clock ticks** unless noted (MD master clock =
  53.693175 MHz NTSC, 53.203 MHz PAL; 68k runs at ÷7, VDP and YM2612 at ÷7).

## When to Use
- Implementing or debugging any Genesis/Mega Drive hardware emulation: the bus,
  VDP, YM2612, DMA, or sprite pipeline.
- Chasing an emulator bug where raster effects, sample audio, or sprite
  rendering don't match hardware.

## How to use
- When a game's raster effects (Sonic, demos), sample audio, or sprite rendering
  look wrong, check the matching section here.
- Numbers in **bold** are measured values you can assert against.
- All timings are in master clock ticks unless noted.

---

## 1. Bus arbitration (68k / Z80 / VDP)

- When the Z80 accesses ROM the bus arbiter **pauses the 68k**, lets the Z80
  finish, then unpauses the 68k. Components run asynchronously, so timing is
  only roughly predictable. If the 68k is mid-access it finishes first.
- **Measured:** Z80 bus accesses delayed ~**2–5** cycles on average; typical
  Z80 delay ≈ **3.3 Z80 cycles**, typical 68k delay ≈ **11 68k cycles**.
  Reads and writes behave the same. MD3 differs slightly (rebuilt bus).
- If the Z80 requests the bus while the VDP does a DMA from RAM/ROM, or the 68k
  is stalled (FIFO empty read / full write), the Z80 waits for that first.
- ⚠️ Z80 accessing ROM *while the VDP DMAs from 68k RAM* can **corrupt RAM**
  (glitchy address-bus signals — like the C64 VSP bug). This is exactly why
  Sega told devs to pause the Z80 before DMA.
- 68k is ~slower than perfect: **2 of every 128 cycles are stolen** (leftover
  refresh). Result: ~**480 68k cycles per raster line** vs theoretical 488+4/7.
  The steal also delays the Z80 if it hits during its ROM access, EXCEPT when
  the 68k is writing to the VDP — then no delay. No effect during DMA (VDP
  self-compensates: skips 2 fetch cycles per refresh → 10 slots/raster line
  lost for fast DMA, 5 for slow).
- A11000 "memory mode" register: only affects VA4-and-earlier boards (and TMSS
  nulls it); delays DTACK making 68k ~1/3 speed.

## 2. YM2612 (FM sound chip)

- Registers **$30..$FF only exist in an always-rotating shift register**, so the
  chip must wait for the desired register position before overwrite. **Max write
  rate ≈ ½ a YM2612 cycle ≈ 33.6 Z80 cycles** between register-address writes.
- Busy flag is **useless** (dead).
- You **cannot** reliably write both register number and data in a single Z80
  word write — too fast for the chip.
- PCM/DAC input is latched once per cycle; timing **differs MD1 vs MD2** (MD1
  stable, MD2 variable). This is why the same music has audible jitter on some
  hardware. Reading the V-counter for timing is legit — support it.
- DAC output shape differs: MD1 outputs a **short pulse** per voice in rotation;
  MD2 **holds** the value for a while. MD1 shows a nonlinear jump near $7F/$80;
  MD2 adds a 2nd-order filter + distortion.
- "Loud PCM" debug bit: amplifies ~5× (MD2) to ~30× (MD1).

## 3. VDP ports & command latches

- The **command port is wired directly** to the internal address buffer *without
  a latch* (only the appropriate half). After writing the 1st half of an
  address, the next write targets the 2nd half **unless** you hit the
  interrupt/data port first. **bit 7 of the 2nd half starts a DMA.**
- The address buffer **increments** (by reg $F) after each VRAM/VSRAM/CRAM
  read/write; on a data-port write both value and address go into the internal
  **FIFO** and the address increments immediately even if not yet written. If
  FIFO full, the CPU stalls. Corners:
  - **DMA fill/copy run inside** the VDP, CPU NOT stalled; a concurrent
    control-port write corrupts things.
  - **VRAM reads need 2 reads** and, during active scan, wait for the next
    access slot. Writing the control port right after a VRAM read can conflict:
    the incremented address is ANDed with the register number/value, glitching
    the pending register write. Also: reg $17 bit 7 cleared (68k mem source)
    sets a **flag that only clears on DMA** — setting a VRAM address while that
    flag is set **crashes the MD**.
- Status port: **upper 6 bits come from whatever is left on the bus** (often
  the next opcode / pull-up $FFFF). Do NOT zero-fill status reads.

## 4. Picture geometry (basic)
- PAL: 38 top + 224 picture + 32 bottom + 3+3+3 sync + 10 blank = **313** total
  (294 picture/border).
- NTSC: 11 top + 224 + 8 bottom + 3+3+3 sync + 10 blank = **262** total (243+19).
- V30 mode: picture +8 from each border (+16 total).
- H-border: 13 extra left + 14 extra right pixels.
- In H40 the VDP **slows its clock for ~32 pixel-clocks during HBlank** (starts
  24 px after right edge), doesn't affect visible pixels.
- VBlank toggles ~32 px before HBlank → last line before VBlank loses ~32 px at
  its end. **All blanking happens after palette lookup** — CRAM dots won't show
  in blank.

### H/V counter tables
HCounter progression (HSync; VCounter increment / HBlank set / HBlank cleared):
- H32 (RSx=00): 0x00–0x93, 0xE9–0xFF; VC 0x84→0x85; HB set 0x92→0x93; HB clear
  0x04→0x05.
- H40 (RSx=11): 0x00–0xB6, 0xE4–0xFF; VC 0xA4→0xA5; HB set 0xB2→0xB3; HB clear
  0x05→0x06.

VCounter (V28 = M2=0, V30 = M2=1) progression; VBlank set / cleared:
- PAL V28: 0x000–0x102 + 0x1CA–0x1FF.
- NTSC V28: 0x000–0x0EA + 0x1E5–0x1FF.
- PAL V30: 0x000–0x10A + 0x1D2–0x1FF.
- NTSC V30: 0x000–0x1FF (full).
- VBlank set: VCounter 0xDF→0xE0 (PAL) / 0xEF→0xF0 (NTSC). Clear 0x1FE→0x1FF.
- F flag: HCounter 0x00→0x01 while VCounter 0xE0 (PAL) / 0xF0 (NTSC).

### V28/V30 no-border trick
Image always starts at raster line 0. If you switch to V30 during active scan
and back to V28 after line 224 but < 240, the VDP **"forgets" to start the
vertical border** and keeps display active (works on NTSC → 243 lines, no
rolling). Border flag tested constantly: one VDP cycle of V28 at line 224 (or
V30 at 240) starts the border again. HIRQ runs continuously while open.

## 5. ⭐ Sprite rendering (4 phases) — get this right
Sprites use a **write-through cache** storing Y/size/link. Only VRAM writes to
the active sprite-table location update it; **moving the sprite table does NOT
refresh the cache**. The cache watches the full 128KB range even in 64KB mode.

- **Phase 1** (2 H-borders before): checks all 80 sprites, walks the linked
  list (link fields), finds the first **20 visible** (Y + size). Iterates max
  80/64 from sprite 0; a link of 0 **stops the scan**. 2 sprites/VDP cycle,
  ~40 cycles. Output: **20-slot shift register** of visible sprite numbers.
- **Phase 2** (1 line before): fetches X + tile info (Y/size re-fetched →
  evaluated twice/line). Only low 5 bits of (spriteY − rasterY) added to column
  top → changing sprite Y after phase 1 still renders the 32px column. Stores
  X, size, palette, priority, H-mirror + row addr into indexed **20-slot cache**.
- **Phase 3** (HBlank before line): fetch tiles, render into **320-px line
  buffer** (7 bits/px: 4 color + palette + priority). Only **transparent
  pixels** (tile 4 bits = 0) overwrite → earlier sprites win regardless of
  priority. 8-px segment blit (rotate tile to X, write left then right half
  via mask). Runs ahead into unused slots; slots 32–39 alias 0–7.
  - ⚠️ **X=0 render stop**: sprite display pauses when a sprite is read from a
    cache slot with X=0 after a prior slot had X≠0, resuming next line. A
    sprite with X=0 following an X≠0 sprite hides all sprites after it.
- **Phase 4** (the line): line buffer composited as a normal plane. Cleared 7 px
  at a time during read, cleared to 0.

### Memory-access per line (for FIFO/timing)
- VDP does **210 accesses (H40) / 171 (H32)** per line, 1 every 2 cycles, 32
  bits each. Slot letters: H = hscroll, A/a = plane A plane/pixel, B/b = plane
  B, S = sprite tile/x, s = sprite pixel, ~ = 68k access, r = refresh.
- H40: `Hssss AsaaBsbb ((A~aaBSbb)*3 AraaBSbb)*5 ~~ s*23 ~ s*11`
- H32:  `Hssss AsaaBsbb ((A~aaBSbb)*3 AraaBSbb)*4 ~~ s*13 ~ s*13 ~`
- Display disabled → skips nearly all accesses → most cycles become 68k slots.

## 6. Effects of "disable display"
- Stops almost all internal accesses → enables border, blocks sprite output.
  Subtle: plane generator uses bus garbage (last DRAM row); missing an `s`
  cycle disables following sprites; missing `s` delays sprite fetch; missing an
  `H` **keeps previous HScroll**. Midline disable always breaks tiles + sprites;
  only in-border disable is useful.

## 7. H40-mode timing truths
H32/H40 select (reg $1) — 4 combos, real clock diff:
- `0x81` H40:  8 c/px (10 during parts of HBlank); line = **3420** ticks.
- `0x01` fast: H40 8 c/px always; **3360** ticks (2% under, OK).
- `0x80` fast: H32 8 c/px; **2736** ticks (20% under, unusable).
- `0x00` H32:  10 c/px; **3420** ticks.
Switching 0x81↔0x80 mid-line → instability, line double-crunch, gfx bugs, hidden
sprites. Toggling clock can momentarily corrupt VRAM timing.

## 8. DMA speed
- Only 2 speeds: **slow** = writing VRAM in 64KB mode; **fast** = everything
  else (CRAM, VSRAM, VRAM 128KB, DMA fill, data-port reads).
- Fast cost ≈ `words×2.4+5.6` extra 68k cycles.
- Slow ≈ `max(words×2.4+5.6, words×4.7−6)` extra (FIFO-limited >5 words).

## 9. Shadow / Highlight
- **Both A and B low-prio** → pixel **shadowed**.
- If sprite on top (not behind a plane, not transparent):
  - color **63** → sprite not drawn, A/B/G shadows (if not already).
  - color **62** → not drawn; A/B/G highlighted (norm→hi, shadow→norm).
  - otherwise sprite normal, **or dark when all of S+A+B low-prio** and color
    not in {14,30,46}.
- Low 4 sprite bits = **14** → disable shadow.
- Color 14 of palettes 0–2 forced normal (leftover; only palette-3 color 14
  highlights).

## 10. Address mapping (64KB / 128KB / SMS)
- VDP always fetches 32 bits from VRAM; interface presents a 16-bit word.
- 64KB: internal byte order swapped vs 68k → DMA-copy bytes reversed.
- 128KB (reg1 bit7): two banks hold high/low bytes. DMA speed → fast; bit0 of
  write/DMA target ignored; bit16 usable. With only 64KB VRAM: **only lower
  byte stored**, upper lost. Useful for **byte-wide DMA**. 68k VRAM target:
  `(((a&2)>>1)^1)|((a&0x400)>>9)|(a&0x3FC)|((a&0x1F800)>>1)` @ inc 4.
- Sprite cache still watches 128KB — bit 16 triggers cache updates in 64KB mode.

## 11. Access timing (palette writes)
- H40 has **18 CPU access slots**/line: 1 mid-sprite (HBlank, invisible), 15
  mid-tile (first in HBlank = first reachable by HBlank IRQ; next at pixel
  X=−3), 2 between-tiles-and-sprites.
- Use the H40 access list to index exact pixel positions.

## Gotcha checklist
1. Z80↔68k delays (avg 3.3 / 11 cycles) + 2-in-128 steal (~480/line).
2. YM2612 $30+ write every ~33.6 cycles; FIFO queue.
3. Control port 2-half latch + DMA start + reg $17 crash flag.
4. Status upper 6 bits = bus garbage.
5. Sprite 4-phase pipeline; X=0 render-stop bug; moving table doesn't refresh
   sprite cache.
6. Shadow/highlight exact colors (62/63/14/30/46).
7. H/V counter tables.
8. Image/border blanking after palette.

For the complete manifest (the author's full v1.5 doc — debug register, plane
masking AND bugs, 128KB abuse, mode-4 glitches, sprite phase 511 / top-bottom
raster lines, and the full footnote arithmetic), open
`references/kabuto-full.txt`.
Use it when a game exploits exotic VDP behavior and this summary isn't enough.