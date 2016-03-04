## 
#  sets an itimer using sys_setitimer

    .text

.global _start

_start:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rdi
    push %rsi
    push %rdx

    mov $0x4141414141414141, %rax
    push %rax


    # sys_setiitimer = 38
    xor %rax, %rax
    movb $0x26, %al
    
    xor %rdx, %rdx
    xor %rdi, %rdi
    xor %rsi, %rsi


    # current value of the timer = 0
    push %rdx
    movb $0x0a, %dl
    push %rdx


    xor %rdx, %rdx
    push %rdx

    # interval to go off = 10 seconds
    movb $0x0a, %dl
    push %rdx
    # struct itimerval *value = pointer to our struct on stack
    mov %rsp, %rsi


    # struct interval *oldvalue = NULL
    xor %rdx, %rdx

    # int which = ITIMER_REAL = 0
    
    syscall
    
    add $0x20, %rsp
    
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax    
    pop %rbp
    ret
