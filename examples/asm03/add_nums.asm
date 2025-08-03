bits 64
section .bss
	result_len resd 1
section .data
	result_buffer times 22 db 0
	err_arg_amount db "Error: expected 2 arguments.", 10
	err_arg_amount_len equ $ - err_arg_amount
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
; args: rdi = pointer to null-terminated string
; returns: rax = 1 (is number) if all chars are digits, 
;          else 0 (is not number)
is_number:
	push rbx
.compare_loop:
	cmp byte [rdi], '0'
	jl .not_a_number
	cmp byte [rdi], '9'
	jg .not_a_number
	inc rdi
	mov bl, byte [rdi]
	test bl, bl
	jnz .compare_loop
	mov rax, 1
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
	; validate argv[1]
	;
	;   - "rdi" = argv[1]
	;   - loop for each character and check if it's [0-9]
	;   - return a boolean in "rax"
	push rdi
	call is_number
	pop rdi
	test rax, rax
	jz .error_not_a_number
	call str_to_int
	mov r13, rax
	mov rdi, qword [rsp + 8 * 3]
	; validate argv[2]
	;
	push rdi
	call is_number
	pop rdi
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
.error_not_a_number:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_not_a_number
	mov rdx, err_not_a_number_len
	syscall
	mov rax, 60
	mov rdi, 1
	syscall

