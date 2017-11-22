[bits 16]
[org 0x7c00]            ; Define the starting point of the bootloader.
mov ah, 0x0e            ; int 10/ah = 0eh -> scrolling teletype BIOS routine
mov al, [the_secret]    ; Set the low byte to the contents of the stored string.
int 0x10                ; Fire BIOS screen interrupt ( with 0x0e + [the_secret] )

jmp $                   ; Jump endlessly to this line.

os_name:                ; An label that points to the addess where the OS name string is stored.
db "stendex OS"         ; Store the OS name string into memory (db -> Declare Bytes)

times  510-($-$$) db 0  ; When compiled, our program must fit into 512 bytes, with the last two bytes being
                        ; the magic number, so here, tell our assembly compiler to pad out our program with
                        ; enough  zero  bytes (db 0) to bring us to the 510th byte.

dw 0xaa55               ; Last two bytes (one  word) form the  magic number, so BIOS knows we are a boot sector.