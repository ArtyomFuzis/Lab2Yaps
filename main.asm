global _start
%include "lib.inc"
%include "dict.inc"
%include "colon.inc"
%define EXCEPTION_TOO_LONG_STRING 1
%define STRING_MAX 255
section .data
greeting_msg: db "Please enter the string: ", `\n`, 0
nothing_msg: db "Nothing found", `\n`, 0
found_msg: db "Found value: ", `\n`, 0
too_long_msg: db "Too long string", `\n`, 0
section .text

read_line:
	push 	rbx
	xor 	rbx, rbx
.loop:	cmp	rbx, 255
	jg 	.err
	push	rdi
	call	read_char
	pop	rdi
	test 	rax, rax
	je 	.ret
	inc	rbx
	mov	[rdi+rbx-1], al
	jmp	.loop	
.ret:
	mov	rax, rbx
	pop 	rbx
	ret
.err:
	mov	rdi, too_long_msg
	call	print_err
	mov 	rdi, EXCEPTION_TOO_LONG_STRING
	call	exit
_start:
	mov 	rdi, greeting_msg
	call 	print_string
	sub	rsp, 272
	mov	rdi, rsp
	call	read_line
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
	xor 	rdi, rdi
	call 	exit
	ret
