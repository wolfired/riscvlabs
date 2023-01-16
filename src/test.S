.section .rodata

prompt:
    .asciz "Value of t0 = %ld and value of t1 = %ld\n"
prompt_end:

.section .data

.section .init

.globl _start

.section .text

_start:
    la t2, prompt
    la t3, prompt_end
    sub t3, t3, t2
    li t1, 0x1
    neg t0, t1
    j _start

