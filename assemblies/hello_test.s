.text
.global _start

_start:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rdx
    push %rdi
    push %rsi
    push %r8

    xor %rax, %rax
    xor %rdx, %rdx
    xor %rsi, %rsi
    xor %rdx, %rdx

    movb $0x01, %al
    movb $0x01, %dil
    movb $0x0d, %dl
    call msg_setup

    pop %rsi
    syscall

    pop %r8
    pop %rsi
    pop %rdi
    pop %rdx
    pop %rax
    pop %rbp
    ret


msg_setup:
    pop %r8
    call %r8
    .ascii "Hello neo...\12\0"

