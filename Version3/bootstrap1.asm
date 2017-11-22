[org 0x7c00] ; Define the starting point of the bootloader.
mov ah, 0x0e ; int 10/ah = 0eh -> scrolling teletype BIOS routine

; First attempt
;mov al, the_secret ; This will print the address of the sting not the string
;int 0x10

; Second attempt
;mov al, [the_secret] ; This will print if it were not located inside the interrupt vector.
;int 0x10

; Third attempt
;mov bx, the_secret ; works but it verbose
;add bx, 0x7c00
;mov al, [bx]
;int 0x10

; Fourth attempt
mov al, [0x7c00]
int 0x10

jmp $   ; Jump endlessly to this line.

the_secret:
db "x"  ; Store an string with the value x

times  510-($-$$) db 0  ; When compiled, our program must fit into 512 bytes, with the last two bytes being
                        ; the magic number, so here, tell our assembly compiler to pad out our program with
                        ; enough  zero  bytes (db 0) to bring us to the 510th byte.

dw 0xaa55               ; Last two bytes (one  word) form the  magic number, so BIOS knows we are a boot sector.