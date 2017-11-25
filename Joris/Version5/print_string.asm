;===========================================================================[ WRITE STRING ROUTINE ]=-
print_string:  ; Print a string to the screen function.
    pusha                   ; Save the current state of the CPU registers.

    .loop:
        lodsb               ; Load the first byte from the segment register.

        or al, al           ; Compare the al with al.
        jz .return          ; If al contains an zero (string termination character) halt execution.
        or eax,0x0300       ;
        mov word [ebx], ax  ;
        add ebx, 2          ; Increase the counter by 2.
        jmp .loop           ; Go to the next character to print.

    .return:
        popa                ; Restore the CPU registers to the previous state.
        ret                 ; Go back to the previous routine.
