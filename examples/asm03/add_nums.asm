bits 64
section .bss
	result_len resq 1
section .data
	result_buffer times 21 db 0
	err_msg db "Error: expected 2 numeric arguments.", 10
	err_msg_len equ $ - err_msg
section .text
	global _start
str_to_int:
	sub rsp, 8
	push rbx
	xor rax, rax
	xor rcx, rcx
.next_digit:
	mov cl, byte [rbx]
	cmp cl, 0
	je .done
	sub cl, '0'
	imul rax, rax, 10
	add rax, rcx
	inc rbx
	jmp .next_digit
.done:
	pop rbx
	add rsp, 8
	ret
int_to_str:
	sub rsp, 8
	push rbx
	mov rcx, 10
	mov rbx, rdi
.convert_loop:
	xor rdx, rdx
	div rcx
	add dl, '0'
	dec rdi
	mov [rdi], dl
	test rax, rax
	jnz .convert_loop
	mov rax, rbx
	sub rax, rdi
	mov [result_len], rax
	pop rbx
	add rsp, 8
	ret
_start:
	mov r12, rsp
	mov rdi, [r12]
	cmp rdi, 3
	jne .not_enough_args
	mov rbx, [r12 + 16]
	call str_to_int
	mov r13, rax
	mov rbx, [r12 + 24]
	call str_to_int
	add rax, r13
	mov rdi, result_buffer + 20
	call int_to_str
	mov rdx, result_len
	mov rsi, rdi
	mov rdi, 1
	mov rax, 1
	syscall
	mov rax, 60
	xor rdi, rdi
	syscall
.not_enough_args:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_msg
	mov rdx, err_msg_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall

