# Attempt at doing hello_world without string definition

  .text

.global _start

_start:
  # Push the old value of RBP onto the stack
  push %rbp
  # Move the current value of the stack pointer (top) to RBP
  mov %rsp, %rbp
  # Reserve 13 bytes on the stack for our data
  sub $0x0D, %rsp

  # Little shendian byte order of "Hello World"
  # Stack will be read from lowest address to highest so we
  # store "Hell" in the lowest addresses and 0x0 in the highest
  movl $0x6c6c6548, -12(%rbp)
  movl $0x6f57206f, -8(%rbp)
  movl $0x0a646c72, -4(%rbp)
  movl $0x0, 0x0(%rbp)

  # Calling:
  #   write(int fd, char * msg, int len)
  # write operand is 1
  mov $0x1, %rax
  # writing to stdout (fd 1)
  mov $0x1, %rdi
  # Zero RSI which is the char * msg
  xor %rsi, %rsi
  # Load the address of the stack pointer to RSI
  lea 0x0(%rsp), %rsi
  # Our message is 13 bytes, put it in RDX
  mov $0x0D, %rdx
  # Call OS to print
  syscall

  # Exit cleanly
  mov $60, %rax
  xor %rdi, %rdi
  syscall
  
