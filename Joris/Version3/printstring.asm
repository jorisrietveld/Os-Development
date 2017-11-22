print_string:
    pusha   ; Store the current CPU register state to the stack so we can restore it later on.

    .print_char:
    lodsb   ; get an single char
    or al, al ; Check if we reached the string termination character(null byte).
    jz .return ; If the result of the or compare is zero return.

    mov ah, 0x0E    ; Set the high bit of the accumilator register to an tellytype operation.
    int 0x10        ; Fire an interrupt that writes the character to the screen.
    jmp .print_char ; Go the the next character.

    .return:
     popa   ; Restore the CPU register state to the state before executing this function.
    ret     ; Done printing the string return to the previous routine.