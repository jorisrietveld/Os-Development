;===========================================================================[ WRITE STRING ROUTINE ]=-
print_string:  ; Print a string to the screen function.
    lodsb           ; Get byte from the segment index register.
    or al, al       ; logical or on al register, are there we done printing characters?
    jz .return      ; Then return to the main routine.

    mov ah, 0x0E    ; Otherwise fetch an new character.
    int 0x10        ; And print the character to the screen with an BIOS interrupt.
    jmp print_string ; Go the the next character.

    .return:
        ret    ; Back to main routine.