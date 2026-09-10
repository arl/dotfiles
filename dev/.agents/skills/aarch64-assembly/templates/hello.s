// hello.s — AArch64 Linux syscall hello world (no libc)
// Build:  gcc -nostdlib -static -o hello hello.s
// Run:    ./hello ; echo "exit=$?"
// Verified output: "hello from aarch64", exit=0

.section .rodata
msg:
    .ascii  "hello from aarch64\n"
msg_end:

.section .text
.global _start
_start:
    mov     x0, #1          // fd = stdout
    ldr     x1, =msg        // buf
    ldr     x2, =msg_end
    sub     x2, x2, x1      // len = msg_end - msg
    mov     x8, #64         // __NR_write
    svc     #0
    mov     x0, #0          // status
    mov     x8, #93         // __NR_exit
    svc     #0