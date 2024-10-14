%include "words.inc"
%include "colon.inc"
%include "lib.inc"
global find_word

section .text
find_word:
	push 	rbx
	mov	rbx, PREV_KEY
.loop:	
	cmp 	rbx, PREV_START_KEY
	je 	.nfound
	mov	rsi, [rbx+OF_KA]
	push 	rdi
	call 	string_equals
	pop 	rdi
	test	rax, rax
	jne 	.found
	mov 	rbx, [rbx+OF_PA]
	jmp 	.loop
		
.nfound:
	xor	rax, rax
	jmp 	.end
.found:
	mov 	rax, rbx
.end:
	pop	rbx
	ret

