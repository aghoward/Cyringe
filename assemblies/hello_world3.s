  .text
# Allows the compiler to see the _start label, which is the first
# routine called upon startup
.global _start

# Create a label _start in this case it is a subroutine
_start:
  # Save RBP on the stack
  push %rbp
  mov %rsp, %rbp


  # Now we are going to use a system call to output the message.
  # Syntax for this is:
  #   write (int fd, cont char *message, int length)
  # syscall for write is 1, this gets stored in RAX
  movb $0x01, %al
  # RDI is first input
  movb $0x01, %dil
  # RSI is second input and should be a memory address
  #mov $MSG, %rsi
  call MSG

end:
  pop %rsi
  # RDX is third parameter
  movb $0x0d, %dl
  # Tell the os to call the routine
  syscall

  # Now let's exit cleanly
  #   exit(0)
  mov $60, %rax
  xor %rdi, %rdi
  syscall

  ret


MSG:
  call end
  .asciz "Hello neo...\12"


