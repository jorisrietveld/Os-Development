;=========================================================================[ STRING COMPARE ROUTINE ]=-
string_compare:;Compare strings in source and data register
.compare:
    mov al, [si]    ; Load an byte from the source index register.
    mov bl, [di]    ; Load an byte from the data index register.
    cmp al, bl      ; Compare the 2 registers, are they different?
    jne .return_false; Then call not equal to set the cary flag to false.

    cmp al, 0       ; are both byes null?
    je .return_true ; Then we're done comparing the strings.

    inc di          ; Increment the data index
    inc si          ; Increment the source index
    jmp .compare    ; Go to the next character to compare in the string.

.return_false:
    clc             ; The strings are not the same, set the cary flag to false.
    ret             ; return to main routine.

.return_true:
    stc             ; The strings are the same, set the cary flag to true.
    ret             ; return to main routine.