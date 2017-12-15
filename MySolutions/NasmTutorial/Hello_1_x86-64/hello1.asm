;_________________________________________________________________________________________________________/ Data Section
;   This section is used to define immutable data like constants, buffer sizes, file names etc. This data should not
;   chance during runtime.
section .data
	msg db "Some random message that is not a hello world..."   ; char * msg    An array with characters.

;_________________________________________________________________________________________________________/ Text Section
;   This section is used to to store executable instructions. It is required to declaten a global _start at the
;   beginning of the section so the kernel is able to figure out where the instructions start.
section .text
	global _start       ; Define the entry point of the program.

_start:                 ; The actual starting location of the program.
	mov 	rax, 1      ; sys_write(        The type of linux syscall.
	mov 	rdi, 1      ; unsigned int fd   File descriptor [0] standard input, [1] standard output, [2] standard error.
	mov 	rsi, msg    ; const char * buf  Pointer to the char array that contains the message.
	mov 	rdx, 48     ; size_t count      The number of bytes to be written the of the buffer
	syscall  			; )					Execute the syscall.
	mov 	rax, 60		; exit(				The type of syscall, exit.
	mov 	rdi, 0		; EXIT_SUCCESS		The exit status code, success;
	syscall 			; )					Execute the syscall.
