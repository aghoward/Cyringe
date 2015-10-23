  .text
# Allows the compiler to see the _start label, which is the first
# routine called upon startup
.global _start

# Create a label _start in this case it is a subroutine
_start:
  # Save RBP on the stack
  push %rbp
  mov %rsp, %rbp

  push %rax
  push %rdi
  push %rsi
  push %rdx


  # Now we are going to use a system call to output the message.
  # Syntax for this is:
  #   write (int fd, cont char *message, int length)
  # syscall for write is 1, this gets stored in RAX
  movb $0x01, %al
  # RDI is first input
  movb $0x01, %dil

  call end
  .ascii "Hello neo...\12\0"

end:
  pop %rsi
  # RDX is third parameter
  movb $0x0d, %dl
  # Tell the os to call the routine
  syscall

  pop %rdx
  pop %rsi
  pop %rdi
  pop %rax
  pop %rbp
  ret



