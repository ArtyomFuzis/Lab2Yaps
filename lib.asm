global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_int
global parse_uint
global string_copy
global print_err
%define SYS_EXIT 60
%define SYS_READ 0
%define SYS_WRITE 1
%define STDIN 0
%define STDOUT 1
%define STDERR 2
section .text
 
; Принимает код возврата и завершает текущий процесс
exit: 
	mov	rax, SYS_EXIT
	syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
	sub 	rsp, 8
	mov 	rcx, rdi
.string_cnt_loop:
	mov 	al, [rcx]
	test 	al, al
	jz 	.string_cnt_ret
	inc 	rcx
	jmp 	.string_cnt_loop
.string_cnt_ret:
	mov 	rax, rcx
	sub 	rax, rdi
	add 	rsp, 8
	ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
	push 	rdi
	call 	string_length
	mov 	rdx, rax
	pop 	rsi
	mov 	rdi, STDOUT
	mov 	rax, SYS_WRITE
	syscall
	ret

print_err:
	push 	rdi
	call 	string_length
	mov 	rdx, rax
	pop 	rsi
	mov 	rdi, STDERR
	mov 	rax, SYS_WRITE
	syscall
	ret


; Принимает код символа и выводит его в stdout
print_char:
	push 	rdi
	mov 	rdi, rsp
	call 	print_string
	add 	rsp, 8
	ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
	mov 	rdi, `\n`
 	jmp 	print_char 

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
	enter 	32, 0
	mov 	rcx, rbp
	dec 	rcx
	mov 	byte [rcx], 0
	mov 	rax, rdi
	mov 	r8, 10
.div_loop:
	xor 	rdx, rdx
	div 	r8
	dec 	rcx
	add 	dl, `0`
	mov 	[rcx],dl
	test	rax, rax
	jne 	.div_loop
	mov 	rdi, rcx
	call 	print_string
	leave
	ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
	test 	rdi, rdi
	jns 	print_uint
	push 	rdi
	mov 	rdi, `-`
	call 	print_char
	pop 	rdi
	neg 	rdi
	jmp 	print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
	mov 	dl, [rdi]
	mov 	cl, [rsi]
	cmp 	cl, dl
	jne	.string_nequ 
	cmp	dl, 0
	je 	.string_equ
	inc rdi
	inc rsi
	jmp string_equals
.string_equ:
	mov	rax, 1
	ret
.string_nequ:	
	xor 	rax, rax
	ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
	sub 	rsp, 8
	mov 	rax, SYS_READ
	mov 	rdi, STDIN 
	mov 	rsi, rsp
	add	rsi, 7
	mov 	rdx, 1
    	syscall
	test 	rax, rax
	jz	.read_char_end
	mov 	rsi, rsp
	add	rsi, 7
	xor 	rax, rax
	mov 	al, [rsi]
.read_char_end:
	add 	rsp, 8
	ret  

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_word:
	push 	rbx
	sub	rsp, 8
	xor 	rbx, rbx
	xor 	rdx, rdx
.read_loop:
	push 	rdi
	push 	rsi
	push 	rdx	
	call	read_char
	pop	rdx
	pop	rsi
	pop	rdi
	cmp 	rax, `\n`
	je 	.switcher
	cmp 	rax, `\t`
	je  	.switcher
	cmp 	rax, ` `
	je 	.switcher
	test	rax, rax
	je 	.read_ending
	mov 	rbx, 1
	add	rdx, 2
	cmp	rdx, rsi
	jg	.read_badending
	sub 	rdx, 2
	mov 	[rdi+rdx], rax
	inc 	rdx
	jmp	.read_loop
.switcher:
	cmp 	rbx, 1
	je 	.read_ending
	jmp 	.read_loop
.read_ending:	
	xor 	rbx, rbx
	mov 	[rdi+rdx], bl
	mov 	rax, rdi
	add	rsp, 8
	pop	rbx
	ret
.read_badending:
	add	rsp, 8
	pop 	rbx
	xor 	rax, rax
	ret

 

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
	xor 	r8, r8
	xor 	rax, rax
	xor 	rcx, rcx
	mov 	rsi, 10
.parse_loop:
	mov 	cl, [rdi+r8]
	cmp	rcx, '0'
	jl 	.parse_end
	cmp 	rcx, '9'
	jg 	.parse_end
	inc 	r8
	mul 	rsi
	sub 	rcx, '0'
	add 	rax, rcx
	jmp 	.parse_loop
.parse_end:
	mov 	rdx, r8
	ret




; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
	sub 	rsp, 8
	xor 	rcx, rcx
	mov 	cl, [rdi]
	cmp	rcx, `-`
	je 	.parse_neg
	call	parse_uint
	add 	rsp, 8
	ret
.parse_neg:
	inc 	rdi
	call	parse_uint
	neg 	rax
	inc 	rdx
	add 	rsp, 8
	ret 

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
	xor 	rax, rax
	xor 	rcx, rcx
.copy_loop:
	cmp 	rax, rdx
	jge 	.copy_fail	
	mov 	cl, [rdi+rax]
	mov 	[rsi+rax], cl
	inc 	rax
	test	cl, cl
	je 	.copy_end
	jmp	.copy_loop
.copy_end:
	ret
.copy_fail:
	xor 	rax,rax
	ret
