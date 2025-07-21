# this file explains "echo_input.asm"

# this program is written for NASM x86_64 System V ABI

# ".bss" defines a section for uninitialized data
#
# "resb" means reserve byte, assigns single bytes to a memory 
#        location labeled as "buffer", times the magnitude 
#        next to the "resb" operator: 64 bytes
section .bss
	buffer resb 64

_start:
	# "1" corresponds to the write syscall
	mov rax, 1
	# for syscalls, "rdi" holds the first argument
	# here, "1" is the fd for stdout
	mov rdi, 1
	# "rsi" holds the second argument
	# moves the address of "prompt" into "rsi
	mov rsi, prompt
	# "rdx" holds the third argument
	# moves "prompt_len" into "rdx"
	mov rdx, prompt_len
	# execute system service number 1
	# write(1, prompt, prompt_len)
	syscall
	# "0" corresponds to the read syscall
	mov rax, 0
	# "rdi" holds the first argument
	# here, "0" is the fd for stdin
	mov rdi, 0
	# "rsi" holds the second argument
	# it's the destination buffer
	mov rsi, buffer
	# "rdx" holds the third argument
	# it's the maximum bytes to read
	mov rdx, 64
	# execute system service number 0
	# read(0, buffer, 64)
	syscall
	# "rdx" holds the third argument
	# "rax" holds the return value of the syscall
	#       corresponds to the bytes read
	mov rdx, rax
	# "1" corresponds to the write syscall
	mov rax, 1
	# for syscalls, "rdi" holds the first argument
	# here, "1" is the fd for stdout
	mov rdi, 1
	# "rsi" holds the second argument
	# moves the address of "buffer" into "rsi"
	mov rsi, buffer
	# execute system service number 1
	# write(1, buffer, rax)
	syscall
	# "60" corresponds to the exit syscall
	mov rax, 60
	# quickly zero out a register
	xor rdi, rdi
	# execute system service number 60
	# exit(0)
	syscall
