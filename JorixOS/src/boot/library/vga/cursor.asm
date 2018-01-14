;__________________________________________________________________________________________/ cursor.asm.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 14-01-2018 10:53
;   
;   Description:
;
_cursorPositionX db 0
_cursorPositionY db 0

;_________________________________________________________________________________________________________________________/ ϝ moveCursor32
;   Description:
;   This updates the hardware cursor using the CRT microcontroller that is part of VGA. Because we are calculating
;   the relative position of the cursor we can ignore the the byte alignment. SO Position = X + Y * COLUMNS
;
;   Function Arguments:
;   bl      For setting the X position.
;   bh      For setting the y position.
bits 32

%define VGA_CRT_INDEX_REG   0x3D4
%define VGA_CRT_DATA_REG    0x3D5

moveCursor:
    pushad                              ; Save the current register states.

    ; Get the current position.
    xor eax, eax                        ; Clear the eax register.
    mov ecx, COLUMNS                    ; Get the number of columns there are in a single line.
    mov al, bh                          ; Get the Y position that was passed as argument.
    mul ecx                             ; Multiply Y by the amount of columns.
    add al, bl                          ; And finally add X to it.
    mov ebx, eax                        ; Save the value to the Base Register.

    ; Set the cursor low to the VGA CRT register (see CRT table above)
    mov al, 0x0F                        ; Get the CRT cursor location low address.
    mov dx, VGA_CRT_INDEX_REG           ; Get the VGA CRT index register address.
    out dx, al                          ; Write the cursor location low to the CRT index register.
    mov al, bl                          ; Get the X position that was passed as an argument.
    mov dx, VGA_CRT_DATA_REG            ; Get the VGA CRT data register address.
    out dx, al                          ; Write the X position to the to the VGA CRT data register.

    ; Set the cursor high to the VGA CRT register (see CRT table at the bottom of this file.)
     mov al, 0x0E                       ; Get the CRT cursor location high address.
     mov dx, VGA_CRT_INDEX_REG          ; Get the VGA CRT index register address.
     out dx, al                         ; Write the cursor location low to the CRT index register.
     mov al, bh                         ; Get the Y position that was passed as an argument.
     mov dx, VGA_CRT_DATA_REG           ; Get the VGA CRT data register address.
     out dx, al                         ; Write the Y position to the to the VGA CRT data register.

     ; Return
     popad                              ; Restore the register states.
     ret                                ; Return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ cursorLocation32
;   Description:
;   Move the cursor to an specific location on the screen.
;
;   Function Arguments:
;   al      For setting the X position.
;   ah      For setting the Y position.
moveToXY:
    pushad                          ; Save the CPU registers.
    mov byte[_cursorPositionX], al  ; Set the X position of the cursor to 0, to start at the first column.
    mov byte[_cursorPositionY], ah  ; Set the Y position of the cursor to 0, to start at the first line.
    popad                           ; Restore the CPU registers.
    ret

disableCursor:
    pushf
    push eax
    push edx

    mov dx, 0x3D4
    mov al, 0xA
    out dx, al

    inc dx
    mov al, 0x20
    out dx, al

    pop edx
    pop eax
    popf
    ret
