;_____________________________________________________________________________________________________________/ main.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 17-12-2017 14:08
;   
;   Description:
;   This file shows ho to use the stack with x86-64 assembler.

;_________________________________________________________________________________________________________/ Data Section
;   This section is used to define immutable data like constants, buffer sizes, file names etc. This data should not
;   chance during runtime.
section .data
    SYS_WRITE   equ 1
    STD_IN      equ 1
    SYS_EXIT    equ 60
    EXIT_CODE   equ 0
    NEW_LINE    db 0xa
    WRONG_ARGC  db "Wong argument count, 2 arguments expected.", 0xA

;_________________________________________________________________________________________________________/ Text Section
;   This section is used to to store executable instructions. It is required to declaten a global _start at the
;   beginning of the section so the kernel is able to figure out where the instructions start.
section .text
    global _start

_start:
    pop rcx
    cmp rcx, 3
    jne argCountError

    add rsp, 8
    pop rsi
    call string_to_int

    mov r10, rax
    pop rsi
    call string_to_int

    add r10, r11

