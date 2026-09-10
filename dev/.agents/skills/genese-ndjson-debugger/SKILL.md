---
name: genese-ndjson-debugger
description: Use when debugging the genese Sega Genesis emulator autonomously via its NDJSON debug protocol. Covers launching the headless debugger, the full protocol reference, and battle-tested workflows for diagnosing emulation bugs (wrong rendering, CPU misbehavior, DMA issues, etc.).
version: 1.0
author: Generated from genese source (emu/debugger/, protocol/server.go, main.go)
metadata:
  tags: [genese, sega-genesis, emulation, debugging, ndjson, protocol]
---

# Genese NDJSON Debugger — Agent's Guide to Autonomous Debugging

This skill teaches an agent how to drive the genese headless debugger over
NDJSON to diagnose emulation bugs **without human intervention**. The debugger
gives you full introspection: registers, memory, disassembly, breakpoints,
watchpoints, stepping at instruction/scanline/frame granularity, and screen
captures.

## Architecture

```
Agent ──(NDJSON over stdio/socket)──▶ protocol.Server ──▶ debugger.Debugger ──▶ m68k CPU (Trace/PC)
```

The CPU calls `Trace(pc)` before **every** instruction. When the debugger wants
to halt, `Trace()` blocks until the agent sends `"continue"` or `"step"`. This
is a **synchronous** halt — the emulator clock stops.

---

## 1. Launching the debugger

```bash
# stdio mode (agent talks on stdin, reads responses on stdout; stderr = logs)
./genese --dbg-server game.bin 2>/tmp/genese.log

# Socket mode (agent connects via TCP or Unix socket)
./genese --dbg-listen tcp:127.0.0.1:9999 game.bin
./genese --dbg-listen /tmp/genese.sock game.bin
```

**Critical**: In `--dbg-server` mode, stdout is the NDJSON stream. All logs go
to stderr. Never write to stdout from agent scripts that pipe into genese.

The emulator starts **halted** (all CPUs paused). The first event you'll receive
is:

```json
{"event":"stopped","reason":"pause","cpu":0,"pc":512}
```

**No handshake needed.** The debugger is immediately ready for commands.

---

## 2. NDJSON wire format

One JSON object per line, newline-terminated. No framing beyond newlines.

### Request envelope (agent → genese)

```json
{"id":1,"method":"commandName","params":{...}}
```

- `id` (int, required): correlation ID; response echoes it
- `method` (string, required): command name
- `params` (object, optional): command arguments

### Response envelope (genese → agent)

```json
{"id":1,"result":{...}}
```
or
```json
{"id":1,"error":"error message string"}
```

### Events (genese → agent, unsolicited, no `id` field)

```json
{"event":"stopped","reason":"breakpoint","cpu":0,"pc":26724,"message":"breakpoint at 00006864"}
{"event":"running"}
{"event":"exited"}
```

- `event`: `"stopped"` | `"running"` | `"exited"`
- `reason` (stopped only): `"breakpoint"` | `"watchpoint"` | `"step"` | `"pause"` | `"manual"` | `"exit"`
- `cpu`, `pc`, `message`: context for the stop

---

## 3. Complete command reference

Every command needs an `id` and `method`. Responses have the same `id` with
`result` or `error`.

### 3.1 Execution control

| Method | Params | Result | Notes |
|--------|--------|--------|-------|
| `state` | none | `{state,reason,cpu,pc,message}` | Current debugger state |
| `pause` | none | `{ok:true}` | Async halt; wait for `event:stopped` |
| `continue` | none | `{ok:true}` | Resume all CPUs; expect `event:running` |
| `step` | none | `{ok:true}` | Single instruction on current CPU |
| `stepScanline` | none | `{ok:true}` | Run until next scanline boundary |
| `stepFrame` | none | `{ok:true}` | Run until next frame boundary |
| `stepOver` | none | `{ok:true}` | Step over calls (installs one-shot at return addr) |
| `runTo` | `{pc: uint32}` | `{ok:true}` | Run until PC hit (one-shot breakpoint) |
| `exit` | none | `{ok:true}` | Shut down; expect `event:exited` |

### 3.2 Breakpoints

| Method | Params | Result | Notes |
|--------|--------|--------|-------|
| `addBreakpoint` | `{pc: uint32}` | `{id: uint32}` | Returns stable ID; deduplicated by PC |
| `removeBreakpoint` | `{id: uint32}` | `{ok: bool}` | Remove by ID |
| `removeBreakpointAt` | `{pc: uint32}` | `{ok: bool}` | Remove by address |
| `listBreakpoints` | none | `[{id,pc},...]` | All active breakpoints |

### 3.3 Watchpoints

| Method | Params | Result | Notes |
|--------|--------|--------|-------|
| `addWatchpoint` | `{addr: uint32}` | `{id: uint32}` | Always read+write |
| `removeWatchpoint` | `{id: uint32}` | `{ok: bool}` | |
| `listWatchpoints` | none | `[{id,addr,read,write},...]` | |

**Warning**: Watchpoints require the CPU to call `WatchRead`/`WatchWrite` in
its memory access handlers. As of the current codebase, the m68k CPU does **not**
call these, so watchpoints will not fire. They are infrastructure ready but not
wired into the CPU core yet.

### 3.4 Register inspection & modification

| Method | Params | Result |
|--------|--------|--------|
| `registers` | `{cpu?: int}` | `{names,values,specialNames,specialValues,pc}` |
| `writeRegister` | `{cpu?: int, index: int, value: uint32}` | `{ok:true}` |

Register index order: D0=0, D1=1, ..., D7=7, A0=8, ..., A7=15, SR=16, USP=17, SSP=18, PC=19.

Example response:
```json
{
  "names":["D0","D1","D2","D3","D4","D5","D6","D7","A0","A1","A2","A3","A4","A5","A6","A7","SR","USP","SSP","PC"],
  "values":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16711680,10240,0,16711680,26724],
  "specialNames":["Status","Insn","Clock"],
  "specialValues":["0000 S:--0-.....","m68k","1024"],
  "pc":26724
}
```

Special registers: Status = SR flags as string (e.g. `"2700 S:--7-....."`),
Insn = CPU type, Clock = cycle count.

### 3.5 Memory inspection

| Method | Params | Result |
|--------|--------|--------|
| `readMemory` | `{cpu?: int, addr: uint32, size: int}` | `{addr,size,bytes:"hex..."}` |

`size` is capped at 1 MiB. Reads go through the CPU's `MemReader` interface:
direct-mapped regions (ROM/RAM) via pointer, MMIO fallback via bus reads.

### 3.6 Disassembly

| Method | Params | Result |
|--------|--------|--------|
| `snapshot` | `{cpu?: int, nlines?: int}` | Full snapshot (registers + instruction-aligned disasm window) |
| `disassemble` | `{cpu?: int, pc: uint32, n: int}` | `[{pc,bytes:"hex",text},...]` |

`snapshot` is the workhorse. It returns everything in one call:
```json
{
  "cpu":0, "pc":26724, "pcIndex":7,
  "regs":{...},
  "call":[26724],
  "disasm":[
    {"pc":26714,"bytes":"48780004","text":"pea     4(a0)"},
    {"pc":26718,"bytes":"4878000c","text":"pea     12(a0)"},
    ...
  ]
}
```

- `pcIndex`: index of current PC within `disasm` array (-1 if outside window)
- `call`: recent call chain (reversed stack, most recent last)
- Disassembly is **instruction-aligned** — no garbage/misaligned entries

### 3.7 Screen capture

| Method | Params | Result |
|--------|--------|--------|
| `screen` | none | `{width,height,format:"png",image:"base64..."}` |

Capture the current rendered frame as a base64-encoded PNG. The frame is copied
from the live buffer — safe to call while paused. **Always call while paused**
to get a stable frame.

### 3.8 CPU selection

| Method | Params | Result |
|--------|--------|--------|
| `getCPU` | none | `{cpu: int}` |
| `setCPU` | `{cpu: int}` | `{ok:true}` |

Currently only CPU 0 (the 68k) is active. Z80 is a stub.

---

## 4. Autonomous debugging workflows

### 4.1 Diagnosing a crash / hang

```
1. Start with --dbg-server (emulator starts paused at PC of first instruction)
2. Get initial state: {"id":1,"method":"snapshot","params":{"nlines":20}}
3. Set breakpoints at known bad addresses (from logs, assertions, etc.)
4. {"id":2,"method":"continue"}
5. Wait for event:stopped
6. On stop: inspect registers, memory, disassembly
7. Step through: {"id":3,"method":"step"} → inspect → repeat
```

### 4.2 Finding where a register gets a wrong value

```
1. Pause the emulator
2. Write a sentinel value to the register: {"id":1,"method":"writeRegister","params":{"index":0,"value":4660}}
3. Continue execution
4. Periodically pause and check: {"id":2,"method":"registers"}
5. When the value changes unexpectedly, you're near the bug
```

### 4.3 Diagnosing rendering bugs (per-frame approach)

```
1. {"id":1,"method":"stepFrame"}  — wait for event:stopped
2. {"id":2,"method":"screen"}    — capture the frame
3. Decode base64 PNG, analyze pixels
4. Set breakpoints at VDP register write handlers
5. {"id":3,"method":"continue"}
6. On breakpoint hit: inspect what's being written to which VDP register
```

### 4.4 Tracing execution around a suspicious address

```
1. {"id":1,"method":"addBreakpoint","params":{"pc":0x1234}}
2. {"id":2,"method":"continue"}
3. On breakpoint hit:
   a. snapshot for full context
   b. step instruction-by-instruction with {"method":"step"}
   c. read memory at addresses accessed by the current instruction
```

### 4.5 Reading VDP memory (VRAM, CRAM, VSRAM)

These are at known addresses in the 68k address space:
- VRAM: typically mapped in the `0xC00000`–`0xC0FFFF` range (word-addressed)
- CRAM: `0xC00000` + offset (see VDP docs)
- VSRAM: `0xC00000` + offset

Use `readMemory`:
```json
{"id":1,"method":"readMemory","params":{"addr":12582912,"size":256}}
```

The m68k `ReadMemory` maps these through `FetchPointer` for direct regions and
falls back to bus reads for MMIO.

### 4.6 Checking DMA state

The VDP DMA engine lives in `vdp_dma.go`. To debug DMA:
```
1. Set breakpoints at DMA start/finish routines (look for DMA-related function addresses)
2. Use {"method":"step"} to trace through the DMA transfer
3. Read VRAM before and after to verify the transfer
```

---

## 5. Example agent interaction (complete session)

```
← {"event":"stopped","reason":"pause","cpu":0,"pc":512}

→ {"id":1,"method":"state"}
← {"id":1,"result":{"state":"paused","reason":"pause","cpu":0,"pc":512,"message":"pause"}}

→ {"id":2,"method":"snapshot","params":{"nlines":16}}
← {"id":2,"result":{...full snapshot...}}

→ {"id":3,"method":"addBreakpoint","params":{"pc":26724}}
← {"id":3,"result":{"id":0}}

→ {"id":4,"method":"continue"}
← {"id":4,"result":{"ok":true}}
← {"event":"running"}

... time passes ...

← {"event":"stopped","reason":"breakpoint","cpu":0,"pc":26724,"message":"breakpoint at 00006864"}

→ {"id":5,"method":"registers"}
← {"id":5,"result":{"names":["D0",...],"values":[42,...],"pc":26724,...}}

→ {"id":6,"method":"readMemory","params":{"addr":16711680,"size":256}}
← {"id":6,"result":{"addr":16711680,"size":256,"bytes":"00000000..."}}

→ {"id":7,"method":"step"}
← {"id":7,"result":{"ok":true}}
← {"event":"stopped","reason":"step","cpu":0,"pc":26728}

→ {"id":8,"method":"exit"}
← {"id":8,"result":{"ok":true}}
← {"event":"exited"}
```

---

## 6. Agent implementation guidelines

### Reading responses
- Read one line at a time from stdout.
- Parse JSON. Check for `"id"` to correlate responses.
- If the object has `"event"` without `"id"`, it's an unsolicited event.
- If it has `"id"` and `"result"`, it's a success response.
- If it has `"id"` and `"error"`, the command failed.

### Idempotency
- `addBreakpoint` on the same PC returns the existing ID (safe to call twice).
- `removeBreakpoint` / `removeBreakpointAt` with a nonexistent target returns `ok:false`.

### Concurrency
- You can send commands while the emulator is running; responses may be
  interleaved with events.
- Events arrive on their own lines; don't assume a response immediately follows
  your request.

### Timeouts
- Commands that start execution (`continue`, `step*`, `runTo`) respond with
  `{ok:true}` immediately, then emit `event:running`. The actual stop arrives
  later as `event:stopped`.
- Always wait for `event:stopped` before sending inspection commands (registers,
  memory, screen).

### Error handling
- If genese crashes or exits unexpectedly, the pipe closes. Read errors from
  stderr (the log stream, if you redirected it).
- After `event:exited`, the `Done()` channel closes. No further commands will
  work.

---

## 7. Key source files

| File | Role |
|------|------|
| `emu/debugger/debugger.go` | Backend: state machine, breakpoints, watchpoints, stepping, subscriptions |
| `emu/debugger/snapshot.go` | Register reads, disassembly, memory reads, screen capture |
| `emu/debugger/disasm.go` | Smart instruction-aligned disassembly window |
| `emu/debugger/protocol/protocol.go` | Wire types (Envelope, Event, State, etc.) + conversion helpers |
| `emu/debugger/protocol/server.go` | NDJSON server: parses requests, dispatches to backend, serializes responses |
| `emu/debugger/tui/tui.go` | Bubble Tea TUI client (not used by agents, but reference for keybindings) |
| `m68k/debug.go` | CPU-side CPUDebugger/CPU interface implementations |
| `m68k/cpu.go` | Main CPU loop with `dbgCallback(pc)` before every instruction |
| `emulator.go` | Wires debugger into emulator (`startDebugBackend`, screen reader, line/frame hooks) |
| `main.go` | `runDebugServer`: headless frame loop driving emulator from protocol |
| `cli.go` | CLI flags: `--dbg`, `--dbg-server`, `--dbg-listen` |