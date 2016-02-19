##
#  Pre-amble for any code that may need to keep state through
#  writeable memory within it's executable space.
#
#  This grabs the memory address where '_start' begins thus this must
#  be the first portion of your shell-code file. Then uses that 
#  address to reassign a 4096 byte portion of the memory starting here
#  to have permissions rwx

.text
    .global _start

_start:
    push %rbp
    mov %rsp, %rbp

    push %rdi
    push %rsi
    push %rdx

    call doit

mprotect:
    push %rbp
    mov %rsp, %rbp

    # Parameter passed through rdi should be address
    # this is also the first parameter to our syscall

    # rsi = length = one page = 4096
    xor %rsi, %rsi
    movb $0x10, %sil
    shl $0x08, %rsi

    # rdx = protection
    xor %rdx, %rdx
    movb $0x07, %dl

    # sys_mprotect = 10
    xor %rax, %rax
    movb $0x0a, %al

    syscall

    pop %rbp
    ret

doit:
    pop %rdi
    subb $0x0c, %dil
    call mprotect

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp

# This is where the real shell-code begins
