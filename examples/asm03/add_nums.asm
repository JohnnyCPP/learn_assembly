bits 64
section .bss
	result_len resd 1
section .data
	result_buffer times 22 db 0
	err_arg_amount db "Error: expected 2 arguments.", 10
	err_arg_amount_len equ $ - err_arg_amount
	err_overflow db "Error: argument contains more than 18 digits.", 10
	err_overflow_len equ $ - err_overflow
	err_not_a_number db "Error: argument is not a number.", 10
	err_not_a_number_len equ $ - err_not_a_number
section .text
	global _start
str_to_int:
	xor rax, rax
	xor rcx, rcx
.next_digit:
	mov cl, byte [rdi]
	cmp cl, 0
	je .done
	sub cl, '0'
	imul rax, rax, 10
	add rax, rcx
	inc rdi
	jmp .next_digit
.done:
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
is_number:
	push rbx
	xor rax, rax
.compare_loop:
	cmp byte [rdi], '0'
	jl .not_a_number
	cmp byte [rdi], '9'
	jg .not_a_number
	inc rdi
	inc rax
	cmp rax, 18
	ja .integer_overflow
	mov bl, byte [rdi]
	test bl, bl
	jnz .compare_loop
	mov rax, 1
	jmp .done
.integer_overflow:
	mov rax, 2
	jmp .done
.not_a_number:
	mov rax, 0
.done:
	pop rbx
	ret
_start:
	cmp qword [rsp], 3
	jne .error_argc
	mov rdi, qword [rsp + 8 * 2]
	push rdi
	call is_number
	pop rdi
	cmp rax, 2
	je .error_overflow
	test rax, rax
	jz .error_not_a_number
	call str_to_int
	mov r13, rax
	mov rdi, qword [rsp + 8 * 3]
	push rdi
	call is_number
	pop rdi
	cmp rax, 2
	je .error_overflow
	test rax, rax
	jz .error_not_a_number
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
	mov rsi, err_arg_amount
	mov rdx, err_arg_amount_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall
.error_overflow:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_overflow
	mov rdx, err_overflow_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall
.error_not_a_number:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_not_a_number
	mov rdx, err_not_a_number_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall

