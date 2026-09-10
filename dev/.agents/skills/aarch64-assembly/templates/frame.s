// frame.s — non-leaf stack frame with frame pointer, loop, callee-saved x19.
// extern int sum_n(int n); returns 0+1+...+n (n added once more at end).
// Build: gcc -o t2 main.c frame.s   (sum_n(5) = 15, verified)
.section .text
.global sum_n
.type   sum_n, %function
sum_n:
    stp     x29, x30, [sp, #-32]!   // push FP + LR, alloc 32 bytes
    mov     x29, sp                 // FP = SP
    str     x19, [sp, #16]          // preserve callee-saved x19
    mov     w19, wzr                // acc = 0
    mov     w2, wzr                 // i = 0
.Lloop:
    cmp     w2, w0
    b.ge    .Ldone
    add     w19, w19, w2            // acc += i
    add     w2, w2, #1
    b       .Lloop
.Ldone:
    add     w0, w19, w0             // acc + n
    ldr     x19, [sp, #16]          // restore x19
    ldp     x29, x30, [sp], #32     // restore FP/LR, dealloc
    ret
.size   sum_n, .-sum_n