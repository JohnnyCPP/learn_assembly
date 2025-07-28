# this file explains "add_nums.asm"

# TODO:
#   - buffer safety: check that "argv" strings don't overflow "result_buffer"
#   - error handling: validate that arguments are valid integers

section .data
	# declare "result_buffer" memory location and
	# initialize 22 bytes with value 0 into it
	#
	# the "times" directive repeats something a number of times
	#
	# stores memory for up to 20 digits
	# (max length of a 64-bit decimal integer)
	# plus the newline '\n' and null terminator '0' characters
	result_buffer times 22 db 0
	err_msg db "Error: expected 2 numeric arguments.", 10
	err_msg_len equ $ - err_msg
section .text
	global _start
# ##################################################
# converts string in RBX to integer (returns in RAX)
# ##################################################
str_to_int:
	# "rbx" is a callee-saved register, to modify it in the subroutine, 
	#       save its state on the Stack (push) and restore it when 
	#       the subroutine ends (pop), to comply with System V ABI
	push rbx
	# clears "rax" and "rcx"
	xor rax, rax
	xor rcx, rcx
	# labels that start with a dot are "local labels":
	# - it belongs to the previous non-dot label (str_to_int)
	# - it doesn't exist for labels defined under it (int_to_str, _start)
	# - it's a good way to avoid collisions with label names
.next_digit:
	# loads next character into "cl"
	# note:
	#  - an ASCII character is represented with a single byte
	#    (which explains the "byte" size directive)
	#  - "cl" contains the lower 8 bits of "rcx"
	#    (which explains that "rcx" is added to "rax" each iteration)
	mov cl, byte [rbx]
	# if next character is a null terminator, breaks the loop
	cmp cl, 0
	je .done
	# subtracts '0' from the ASCII encoded number, 
	# to get it's decimal representation
	sub cl, '0'
	# multiplies "rax" by 10, to create space for the next digit
	imul rax, rax, 10
	# adds the next digit to "rax"
	add rax, rcx
	# moves pointer in "rbx" to the next character and loops
	inc rbx
	jmp .next_digit
	# the cpu jumps to this label when the null terminator is found
.done:
	pop rbx
	# "ret" pops the return address from the stack and jumps to it:
	# - the return address is pushed onto the stack by "call"
	# - the return address points to the instruction just below "call"
	#   (when "str_to_int" was called in "_start": "call str_to_int")
	ret
# ##########################################################
# converts integer in RAX to string (returns pointer in RDI)
# ##########################################################
int_to_str:
	push rbx
	mov rcx, 10         # sets divisor of "div" to 10, 
	                    # because the integer is base 10
	mov rbx, rdi        # saves the end of the buffer in "rbx"
	# add a newline character
	dec rdi
	mov byte [rdi], 10
.convert_loop:
	# "rdx" is the 64-bit register of 8-bit "dl" 
	# for a 64-bit divisor, "div" requires "rdx" to be zeroed 
	# to avoid garbage values for correct unsigned division
	xor rdx, rdx
	div rcx             # divides "rax" by 10 (rax/rcx) 
	                    # stores the remainder in "rdx"
	add dl, '0'         # encodes current digit to ASCII
	dec rdi             # decreases string pointer by a magnitude of 1
	                    # (filling it from right to left)
	mov byte [rdi], dl  # assigns ASCII encoded digit in current character
	test rax, rax       # checks if "rax" is zero
	jnz .convert_loop   # loops if "rax" is not zero
	mov rax, rbx        # restores the end of the buffer in "rax"
	sub rax, rdi        # computes string length (end - start), because 
	                    # "rdi" has been moved to the left until 
						# there was no more digits to add
						# (so "rdi" is in the first character of the string)
	mov dword [result_len], eax
	pop rbx
	ret
_start:
	# this program starts without libc, the linux kernel 
	# only sets up the arguments in the stack, not registers
	# arguments must be manually extracted from the stack
	# using the stack pointer "rsp"
	mov r12, rsp        # r12 = pointer to argc
	# rdi = argc
	mov edi, dword [r12]
	cmp rdi, 3          # checks the presence of 3 args
	                    # (path_to_executable, num1, & num2)
	# if "rdi" != 3, jumps to label
	jne .error_argc 
	# rbx = argv[1]
	mov rbx, qword [r12 + 8 * 2]
	# the return address pushed by "call" is the address of the first byte 
	# of the next instruction immediately after it, 
	# "ret" pops the return address and jumps to it
	call str_to_int     # gets decimal representation of "rbx" in "rax"
	mov r13, rax        # first number in r13
	# rbx = argv[2]
	mov rbx, qword [r12 + 8 * 3]
	call str_to_int     # gets decimal representation of "rbx" in "rax"
	add rax, r13        # rax += first number
	# "result_buffer + 20" is the pointer to the null terminator 
	# of the result's string representation, because the buffer 
	# has a size of 21 bytes
	mov rdi, result_buffer + 21
	call int_to_str     # gets string representation of "rax" in "rdi"
	# prints result and exits with return code 0
	mov edx, dword [result_len]
	# "rdi" is a pointer to the string representation of the addition 
	# of the two numbers in argv[1] & argv[2]
	mov rsi, rdi
	mov rdi, 1
	mov rax, 1
	syscall             # execute system service number 1
	mov rax, 60
	xor rdi, rdi
	syscall             # execute system service number 60
	# prints "err_msg" and exits with return code 1
.error_argc:
	mov rax, 1
	mov rdi, 2
	mov rsi, err_msg
	mov rdx, err_msg_len
	syscall             # execute system service number 1
	mov rax, 60
	mov rdi, 1
	syscall             # execute system service number 60

