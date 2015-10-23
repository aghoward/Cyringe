##
#  Write a message, spawn a shell with an environment
#  So what's so special about this version over shell2?
#   * objdump -D shell3
#   XD that's right its perfectly valid shell code!

  .text

.global _start

_start:
  # 19 bytes "NSecure Shell Code\n"
  # 1 bytes to terminate
  # 9 bytes "/bin/bash"
  # 1 bytes to terminate
  # 8 bytes zero
  # 8 bytes ptr to str
  # 9 bytes "PS1=o.0$ "
  # 1 bytes to terminate
  # 8 bytes zero
  # 8 bytes ptr to str

  push %rbp
  mov %rsp, %rbp
  sub $0x48, %rsp

  # print str
  movl $0x6365534E, -72(%rbp)
  movl $0x20657275, -68(%rbp)
  movl $0x6c656853, -64(%rbp)
  movl $0x6f43206c, -60(%rbp)
  xor %r8, %r8
  mov $0x6564, %r8w
  mov %r8w, -56(%rbp)
  xor %r8, %r8
#  mov $0x0a, %r8b
  mov %r8b, -54(%rbp)

  # shell name
  movl $0x6e69622f, -52(%rbp)
  movl $0x7361622f, -48(%rbp)
  xor %r8, %r8
  mov $0x68, %r8b
  mov %r8w, -44(%rbp)

  # ptr
  xor %r8, %r8
  lea -52(%rbp), %r8
  mov %r8, -42(%rbp)
  # Zero list terminator
  xor %r8, %r8
  movl %r8d, -34(%rbp)

  # environment
  movl $0x3d315350, -26(%rbp)
  movl $0x24302e6f, -22(%rbp)
  mov $0x20, %r8b
  mov %r8w, -18(%rbp)

  # ptr
  xor %r8, %r8
  lea -26(%rbp), %r8
  mov %r8, -16(%rbp)
  # Zero list terminator
  xor %r8, %r8
  mov %r8d, -8(%rbp)

  #print msg
  mov $0x1, %r8b
  xor %rax, %rax
  mov %r8b, %al
  xor %rdi, %rdi
  mov %r8b, %dil
  lea -72(%rbp), %rsi
  xor %rdx, %rdx
  mov $20, %dl
  syscall

  # spawn shell
  mov $59, %al
  mov -42(%rbp), %rdi
  lea -42(%rbp), %rsi
  lea -16(%rbp), %rdx
  syscall

  #exit
  xor %rdi, %rdi
  mov $60, %al
  syscall
