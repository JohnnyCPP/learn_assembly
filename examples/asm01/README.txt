# this file explains "hello_world.asm"

# this program is written for NASM x86_64 System V ABI

# this assembler directive sets the bit mode to be 64-bits
# allows 64-bit registers
# nasm supports "16" and "32" bit modes too
bits 64

# defines "data" and "text" sections
#
# - the "data" section contains initialized data
# - the "text" section contains assembly instructions
# - a "bss" section is not present, 
#   but would store uninitialized data
section .data
section .text

# declares a memory location whose label is "msg"
# "db" means define byte, assigns a byte to each character
#
# "msg" stores an array of bytes, where the last byte 
# is the ascii number of the newline character:
# "Hello, World!\n"
#
# nasm doesn't support escape sequences, so the newline 
# character is added after a comma
msg db "Hello, World!", 10

# calculates the length of a data block
#
# "equ" means equate, which defines a constant
# "$" references the position of the instruction 
#     or data being assembled at the moment
# "-" this is just a subtraction operator
# "msg" references the start address of the string
#
# in other words, calculates the difference (in bytes) between:
#   - the current address "$"
#   - the starting address of the string "msg"
len equ $ - msg

# makes the "_start" symbol visible to the linker
#
# without it, the symbol remains local to the assembly file, 
# so the linker can't use it as the program's entry point
global _start

# declares a block of code whose label is "_start"
#
# this subroutine is stored in memory, the "_start" is a label 
# representing the address of the first byte of the 
# first instruction of that code block in memory
#
# it's a sequence of instructions that the cpu executes 
# from top to bottom
#
# it's the application's entry point because by convention, 
# the linker sets the "_start" symbol as the entry point 
# by default if it's defined and made global
#
# "_start" is overriding the default "_start" symbol that the 
# linker would provide (from libc)
_start:
	mov rax, 1    # "1" corresponds to the write syscall
    # for syscalls, "rdi" holds the first argument
    # here, "1" is the fd for stdout
	mov rdi, 1
    # "rsi" holds the second argument
    # moves the address of "msg" into "rsi"
	mov rsi, msg
    # "rdx" holds the third argument
    # moves "len" into "rdx"
	mov rdx, len
    # execute system service number 1
    # write(1, msg, len)
	syscall
	mov rax, 60   # "60" corresponds to the exit syscall
	xor rdi, rdi  # quickly zero out a register
    # execute system service number 60
    # exit(0)
	syscall
