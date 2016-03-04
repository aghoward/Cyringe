## 
    .text

.global _start


# This begins our pre-amble, which remaps this space as rwx
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
    subb $0xc, %dil
    call mprotect

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp
##
# End of preamble
##


# This starts the actual shellcode
payload:
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

    call setsignalhandler
    call settimer

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

setsignalhandler:
    # Push the address of our restorer function
    call restorer_addr

    # flags = SA_RESTORER | SA_RESTART
    xor %r8, %r8
    #mov $0x14000000, %r8
    movb $0x14, %r8b
    shl $0x18, %r8
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
    # rdi = int signalNumber (SIGALRM)
    xor %rdi, %rdi
    movb $0x0e, %dil
    # r10 = size_t sigsetsize
    xor %r10, %r10
    movb $0x08, %r10b

    # Install the handler
    syscall

    # Move the stack pointer up to remove our sigaction structure
    add $0x18, %rsp

    ret


settimer:
    # sys_setiitimer = 38
    xor %rax, %rax
    movb $0x26, %al
    
    xor %rdx, %rdx
    xor %rdi, %rdi
    xor %rsi, %rsi


    # current value of the timer = 10
    push %rdx
    movb $0x05, %dl
    push %rdx

    xor %rdx, %rdx
    push %rdx
    # interval to go off = 10 second
    movb $0x05, %dl
    push %rdx

    # struct itimerval *value = pointer to our struct on stack
    mov %rsp, %rsi

    # struct interval *oldvalue = NULL
    xor %rdx, %rdx

    # int which = ITIMER_REAL = 0
    
    syscall
    
    add $0x20, %rsp
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

# This just marks a memory space where we will keep a pointer to the
# message we will print on this pass
msg:
    pop %r8
    call %r8
    #.long $0x00
    # We don't actually care what is here as long as it's not a null
    # this is because this code will never be called
    xor %rax, %rax
    xor %rax, %rax
    movb $0x01, %al

# The first message we will end up printing
msg_a:
    pop %r8
    call %r8
    .ascii "Hello neo...\n"

# Second message to print
msg_b:
    pop %r8
    call %r8
    .ascii "Follow the white rabbit.\n"

# Sets all registers to allow printing msg_a
load_msg_a:
    xor %rdx, %rdx
    xor %rsi, %rsi

    # Get the address of the message
    call msg_a
    pop %r9

    # Get the address of our pointer storage area
    call msg
    pop %r8

    # Move a pointer to our msg (msg_a) into the storage area
    mov %r9, (%r8)
    # Copy our msg pointer to %rsi for syscall later
    mov %r9, %rsi

    # Set the length of our message to print
    movb $0xd, %dl

    ret

# Pretty much the same as load_msg_a, but loads msg_b
load_msg_b:
    xor %rdx, %rdx
    xor %rsi, %rsi

    call msg_b
    pop %r9

    call msg
    pop %r8

    mov %r9, (%r8)
    mov %r9, %rsi

    movb $0x19, %dl

    ret

# This is always called to get the correct msg to load
load_msg:
    xor %r8, %r8
    xor %r9, %r9

    # Get a pointer to our pointer that is in storage
    call msg
    pop %r9
    # Get a pointer to the first msg
    call msg_a
    pop %r8

    # If the first msg is the same as our pointer in storage, load
    # the second msg, else load the first msg
    cmp %r8, (%r9)
    je load_msg_b
    jmp load_msg_a

# Address of our handler function
handler_addr:
    pop %r8
    call %r8

# Signal handler
handler:

    call settimer
    # Note that since we a restorer function we don't need to worry
    # about messing up the registers. The kernel also takes care to
    # provide us our own stack for use here
    xor %rax, %rax
    xor %rdi, %rdi
    xor %rsi, %rsi
    xor %rdx, %rdx

    movb $0x01, %al
    mov %rax, %rdi
    call load_msg

    syscall

    ret
