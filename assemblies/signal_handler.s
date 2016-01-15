##
#  Registers a signal in the host process which prints a message
#  Demonstrates a sort of process scheduler inside another living host

.text

.global _start

_start:
    # Save the hosts' stack
    push %rbp
    mov %rsp, %rbp
    
    # Save the hosts' registers
    push %rax
    push %rsi
    push %rdi
    push %rdx
    push %r8
    push %r10

    # Push the address of our restorer function
    call restorer_addr

    # flags = SA_RESTORER | SA_RESTART
    xor %r8, %r8
    mov $0x14000000, %r8
    push %r8

    # Push the address of our handler function
    call handler_addr

    # syscall sys_rt_sigaction
    xor %rax, %rax
    movb $0xd, %al
    
    # rsi = struct sigaction * action
    mov %rsp, %rsi
    # rdx = struct sigaction * old_action (null cause we don't care)
    xor %rdx, %rdx
    # rdi = int signalNumber (SIGUSR1)
    xor %rdi, %rdi
    movb $0x0a, %dil
    # r10 = size_t sigsetsize
    xor %r10, %r10
    movb $0x08, %r10b

    # Install the handler
    syscall

    # Move the stack pointer up to remove our sigaction structure
    add $0x18, %rsp

    # Restore the hosts' registers
    pop %r10
    pop %r8
    pop %rdx
    pop %rdi
    pop %rsi
    pop %rax
    pop %rbp
    # Return control to the host
    ret

# Address of the restorer
restorer_addr:
    pop %r8
    call %r8

restorer:
    # Pulled from the libc restorer function
    # sys_rt_sigreturn will take care of restoring registers, masks,
    # flags, and the stack for us
    xor %rax, %rax
    movb $0x0f, %al
    syscall

# Address of our handler function
handler_addr:
    pop %r8
    call %r8

# Signal handler
handler:
    # Note that since we a restorer function we don't need to worry
    # about messing up the registers. The kernel also takes care to
    # provide us our own stack for use here
    xor %rax, %rax
    xor %rdi, %rdi
    xor %rsi, %rsi
    xor %rdx, %rdx

    movb $0x01, %al
    mov %rax, %rdi
    call msg
    pop %rsi
    movb $0x0d, %dl

    syscall

    ret

# The message we want to print
msg:
    pop %r8
    call %r8
    .asciz "Hello neo...\n"
