bits 64
section .data
	msg db 'Hello, World!', 0
section .text
	global main
	extern printf
main:
	sub rsp, 8
	lea rdi, [rel msg]
	xor eax, eax
	call printf
	add rsp, 8
	ret
