read_string_func: ; Read key presses from the user.
    pusha
    xor cl, cl      ;

.loop:
    mov ah, 0
    int 0x16        ; Wait for key press.

    cmp al, 0x80    ; Backspace pressed?
    je .back_key    ; Handle the backspace key, it will remove the last char.

    cmp al, 0x0D    ; Enter pressed?
    je .enter_key   ; Were done reading input. go back to the main routine.

    cmp cl, 0x3F    ; Are there 63 characters in the I/O input?
    je .loop        ; Then only allow backspaces or enters

    mov ah, 0x0E    ;
    int 0x10        ; Print the entered character to the screen

    stosb           ; Put the character in the buffer
    inc cl          ;
    jmp .loop       ;

;================================================================================[ BACKSPACE EVENT ]=-
.back_key:;Handle Backspace key
    cmp cl, 0       ; Is it the beginning of the string?
    je .loop        ; Then ignore the the key

    dec di          ; Move back 1 in the string
    mov byte[di], 0 ; Overwrite the char with 0, so the character gets deleted.
    dec cl          ; Also decrement the string length counter.

    mov ah, 0x0E    ;
    mov al, 0x08    ;
    int 10h         ; Backspace on the screen

    mov al, ' '     ; Set an empty space in the buffer.
    int 10h         ; Write the empty space over the character.

    mov al, 0x08    ;
    int 10h         ; Backspace again

    jmp .loop       ; Go to the main loop of the input read function.
;===================================================================================[ ENTER EVENT ]=-
.enter_key:; Handle enter key
    mov al, 0       ; Set an null terminator to the register.
    stosb           ; Append the terminator to the end of the string.

    mov ah, 0x0E    ; Reset accumulator high byte.
    mov al, 0x0D    ; Reset accumulator high byte.
    int 0x10
    mov al, 0x0A    ; Set an newline character to the register.
    int 0x10        ; Insert the newline character
    ret             ; Return to main routine.
.return