;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This file contains an simple "Hello World" bootloader written in the NASM assembler.
;   It is able to print the hello world characters to the screen.
;
;   mov     Move
;   or
;   jz      Jump Zero
;   int     Interupt
;   jmp     Jump
;   cli     Clear Interupt
;   hlt     Halt Execution
;   db      Define Byte
;   lodsb   Load Data Segment Register
;

bits    16          ; Tell NASM the output should be in 16 bit instructions ( Real Mode ).
org     0x7C00      ; Tell MASM the output should start writing at register offset 0x7C00.

; Initiate the program
boot:
    mov si, hello   ; Move content from hello to the source index register, so it can be used to stream to the sceen.
    mov ah, 0x0E    ; Set accumilator register to 0x0E (Ascii controll code: Shift Out, SO).

; For each character in "Hello World!"
loop:
    lodsb           ; Load byte from the data segment register into accumilator low byte register.
    or  al, al      ; Is the value in the accumilator low byte register equal to zero ?
    jz  halt        ; Yes (zero flag is set after arithmetic operation), jump to halt (stop executing).
    int 0x10        ; Call set video mode BIOS interrupt.
    jmp .loop       ; Jump back to the start of the loop.

; Initialize output string.
hello:
    db "Hello World!", 0    ; Define byes representing the string hello world.


times 510 - ($-$$) db 0     ; Fill remaining 510 bytes of MBR with zeros to prevent unexpeced behaveour.


dw 0xAA55 ; Mark this sector (the 512 bytes used in the bootleader) as bootable with the magic constand.