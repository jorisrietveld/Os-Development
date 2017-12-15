section .data
	msg db "Some random message that is not a hello world..."

section .text
	gobal _start

_start:
	mov 	rax, 1
	mov 	rdi, 1
	mov 	rsi, msg
	mov 	rdx, 48
	syscall
	mov 	rax, 60
	mov 	rdi, 0
