# Learn Assembly

I use this repository to store didactic information about Assembly Language.

A program written in Assembly Language depends on the target CPU architecture and the Assembler used. In this case, I'm learning Assembly Language for x86_64 and assembling it with the Netwide Assembler.

A part from making the programs ASLR compatible, I follow System V ABI conventions.

I've chosen NASM over MASM and GAS because it supports a wide range of output formats, like PE, ELF, and Mach-O. The Makefile targets in this repository are configured to produce ELF files, because I'm developing in a Linux system.
