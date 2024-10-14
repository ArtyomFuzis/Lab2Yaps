global _start
%include "lib.inc"
%include "dict.inc"
%include "colon.inc"
%define STDIN 0
%define SYSTEM_READ 0
section .data
greeting_msg: db "Please enter the string: ", `\n`, 0
nothing_msg: db "Nothing found", `\n`, 0
found_msg: db "Found value: ", `\n`, 0
section .text

_start:
	mov 	rdi, greeting_msg
	call 	print_string
	sub 	rsp, 272
	mov 	rax, SYSTEM_READ
	mov 	rdi, STDIN
	mov 	rsi, rsp
	mov 	rdx, 255
	syscall
	test	rax, rax
	je 	.nfound
	cmp 	BYTE [rsp+rax-1], `\n`
	jne 	.nline
	mov 	BYTE [rsp+rax-1], 0
	jmp 	.cont
.nline:
	mov	BYTE [rsp+rax], 0
.cont:
	mov 	rdi, rsp
	call	find_word
	test 	rax, rax
	je 	.nfound
	push 	rax
	mov 	rdi, found_msg
	call	print_string
	pop	rax
	mov 	rdi, [rax+OF_VA]
	call 	print_string
	call 	print_newline
	jmp 	.end
.nfound:
	mov 	rdi, nothing_msg
	call 	print_err 
.end:
	add	rsp, 272
	mov 	rdi, 0
	call 	exit
	ret
