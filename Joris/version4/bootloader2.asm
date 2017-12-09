;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   A simple bootloader that shows an menu and and allows the user to choose an option from the menu.
;
bits    16                  ; Configure NASM for Real Mode.
org     0x7C00              ; Set program output offset at 0x7C00.
jmp     initaite

%include "utils.asm"

initaite:; Initiate the program
    mov ax, 0               ; Initiate the accumulator register with 0.
    mov ds, ax              ; Initiate data segment register with 0.
    mov es, ax              ; Initiate extra segment register with 0.
    mov ss, ax              ; Initiate stack segment register with 0.
    mov sp, 0x7C00          ; Point the top of the stack at address 0x7C00.

    defstr message, "Hello world, my name is bootloader"

    println message

    cli
    hlt



times 510-($-$$) db 0 ; Pad the rest of the first boot sector with zeros.
dw 0xAA55 ; Mark this sector as bootable with black magic.

