bits 64
section .data
	prompt db "Enter something:"
	prompt_len equ $ - prompt
section .bss
	buffer resb 64
section .text
	global _start
_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, prompt
	mov rdx, prompt_len
	syscall
	mov rax, 0
	mov rdi, 0
	mov rsi, buffer
	mov rdx, 64
	syscall
	mov rdx, rax
	mov rax, 1
	mov rdi, 1
	mov rsi, buffer
	syscall
	mov rax, 60
	xor rdi, rdi
	syscall
