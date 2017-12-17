;_____________________________________________________________________________________________________________/ main.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 17-12-2017 00:50
;
;   Description:

;_________________________________________________________________________________________________________/ Data Section
;   This section is used to define immutable data like constants, buffer sizes, file names etc. This data should not
;   chance during runtime.
section .data
	numberOne equ 20	; Set the first numer
	numberTwo equ 22	; And set the second number.
	message db "Yeay we did some hardcore calculations.\n"

;_________________________________________________________________________________________________________/ Text Section
;   This section is used to to store executable instructions. It is required to declaten a global _start at the
;   beginning of the section so the kernel is able to figure out where the instructions start.
section .text
	global _start       ; Define the entry point of the program.

_start:                 ; The actual starting location of the program.
    mov rax, numberOne 	; Move the first number to the accumulator.
    mov rbx, numberTwo 	; Then load the second one in the base register.
    add rax, rbx		; Add the base to the accumulator.
    cmp rax, 42			; Check if the result in rax is equal to 42.
    jne .exit			; If not jump to the exit routine.
    jmp .correct		; Else jump to the routine that prints a message.

    .correct:
        mov rax, 1			; Set rax to 1 for an sys_write syscall.
        mov rdi, 1			; Configure the syscall for standard output.
        mov rsi, message 	; Set the pointer that points to the string starting point.
        mov rdx, 42			; Set the length of the string.
        syscall 			; Make the syscall that prints the string to the std out.
        jmp .exit			; Done printing jump to the exit routine.

    .exit:
        mov rax, 60			; Set the type of syscall to exit.
        mov rdi, 0			; Set the exit status code to 0.
        syscall 			; Exit the program.

