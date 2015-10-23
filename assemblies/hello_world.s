# This is the Hello World program in GAS syntax
#
# Instructions in GAS have the following syntax:
#   instruction source, destination
# e.g.:
#   mov $0x05, %rax
#   # Moves 5 into the RAX general-purpose register
#
# Instructions are generally suffixed with an indicator to operand
# size:
#   b = byte
#   s = short (16-bit int, or 32-bit float)
#   w = word (16-bit)
#   l = long (32-bit int, or 64-bit float)
#   q = quad (64-bit)
#   t = 10 bytes (80-bit float)
# These are optional, if omitted GAS will infer size from operands
#
# Registers are prefixed with "%" and constant numbers are prefixed 
# with "$"
#
# Address operands may be offset in the following syntax:
#   displacement(base register, offset register, scalar)
# Which has the effect of:
#   (base register + displacement + offset register * scalar)
#
# On to the code...

# This tells the compiler where to put the code in memory
# this should be sufficient for most purposes
  .text

# Create a named variable
MSG:
  .ascii "Hello World\12\0"

# Allows the compiler to see the _start label, which is the first
# routine called upon startup
.global _start

# Create a label _start in this case it is a subroutine
_start:
  # Save RBP on the stack
  push %rbp

  # Now we are going to use a system call to output the message.
  # Syntax for this is:
  #   write (int fd, cont char *message, int length)
  # syscall for write is 1, this gets stored in RAX
  mov $0x01, %rax
  # RDI is first input
  mov $0x01, %rdi
  # RSI is second input and should be a memory address
  mov $MSG, %rsi
  # RDX is third parameter
  mov $0x0d, %rdx
  # Tell the os to call the routine
  syscall

  # Now let's exit cleanly
  #   exit(0)
  mov $60, %rax
  xor %rdi, %rdi
  syscall
