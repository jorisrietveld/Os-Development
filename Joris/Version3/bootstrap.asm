mov ah, 0x0e ; int 10/ah = 0eh -> scrolling teletype BIOS routine

mov al, 'H' ; Insert H into the accumulator low register.
int 0x10    ; execute the bios interrupt to print al to the screen
mov al, 'e' ; Insert H into the accumulator low register.
int 0x10    ; execute the bios interrupt to print al to the screen
mov al, 'l' ; Insert H into the accumulator low register.
int 0x10    ; execute the bios interrupt to print al to the screen
mov al, 'l' ; Insert H into the accumulator low register.
int 0x10    ; execute the bios interrupt to print al to the screen
mov al, 'o' ; Insert H into the accumulator low register.
int 0x10    ; execute the bios interrupt to print al to the screen

jmp $   ; Jump endlessly to this line.

the_secret:
db "x"

times  510-($-$$) db 0  ; When compiled, our program must fit into 512 bytes, with the last two bytes being
                        ; the magic number, so here, tell our assembly compiler to pad out our program with
                        ; enough  zero  bytes (db 0) to bring us to the 510th byte.

dw 0xaa55               ; Last two bytes (one  word) form the  magic number, so BIOS knows we are a boot sector.