;===========================================================================[ WRITE STRING ROUTINE ]=-
print_repeat:  ; Print a string to the screen function.
    lodsb

    .loop:
    cmp cl, 0x28
    je .return

    mov ah, 0x0E    ; Otherwise fetch an new character.
    int 0x10
    inc cl
    jmp .loop

    .return:
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0D
    mov ah, 0xAE
    int 0x10
    ret    ; Back to main routine.