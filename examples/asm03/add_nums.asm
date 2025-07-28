bits 64
section .bss
	result_len resd 1
section .data
	result_buffer times 22 db 0
	err_msg db "Error: expected 2 numeric arguments.", 10
	err_msg_len equ $ - err_msg
section .text
	global _start
str_to_int:
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
	ret
int_to_str:
	push rbx
	mov rcx, 10
	mov rbx, rdi
	dec rdi
	mov byte [rdi], 10
.convert_loop:
	xor rdx, rdx
	div rcx
	add dl, '0'
	dec rdi
	mov byte [rdi], dl
	test rax, rax
	jnz .convert_loop
	mov rax, rbx
	sub rax, rdi
	mov dword [result_len], eax
	pop rbx
	ret
_start:
	mov r12, rsp
	mov edi, dword [r12]
	cmp rdi, 3
	jne .error_argc
	mov rbx, qword [r12 + 8 * 2]
	call str_to_int
	mov r13, rax
	mov rbx, qword [r12 + 8 * 3]
	call str_to_int
	add rax, r13
	mov rdi, result_buffer + 21
	call int_to_str
	mov edx, dword [result_len]
	mov rsi, rdi
	mov rdi, 1
	mov rax, 1
	syscall
	mov rax, 60
	xor rdi, rdi
	syscall
.error_argc:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_msg
	mov rdx, err_msg_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall

