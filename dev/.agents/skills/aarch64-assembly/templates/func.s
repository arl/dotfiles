// func.s — AArch64 function using AAPCS64.
// extern int add_it(int a, int b); returns a+b.
// Build with C driver:  gcc -o func main.c func.s
// Verified output: add_it(20, 22) = 42

.section .text
.global add_it
.type   add_it, %function
add_it:
    add     w0, w0, w1     // result = a + b
    ret
.size   add_it, .-add_it