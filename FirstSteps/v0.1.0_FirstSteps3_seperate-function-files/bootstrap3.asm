bits 16
org 0x7c00              ; Define the starting point of the bootloader.

mov ah, 0x0e    ; int  10/ah = 0eh -> scrolling  teletype  BIOS  routine
mov bp, 0x8000  ; Set  the  base of the  stack a little  above  where  BIOS
mov sp, bp      ; loads  our  boot  sector  - so it won’t overwrite  us.
push 'A'        ; Push  some  characters  on the  stack  for  later
push 'B'        ; retreival.   Note , these  are  pushed  on as
push 'C'        ; 16-bit  values , so the  most  significant  byte

; will be  added by our  assembler  as 0x00.
pop bx          ; Note , we can  only  pop 16-bits , so pop to bx
mov al, bl      ; then  copy bl (i.e. 8-bit  char) to al
int 0x10        ; print(al)
pop bx          ; Pop  the  next  value
mov al, bl
int 0x10        ; print(al)
mov al, [0x7ffe]; To  prove  our  stack  grows  downwards  from bp ,

; fetch  the  char at 0x8000  - 0x2 (i.e. 16-bits)
int 0x10        ; print(al)

jmp $           ; Jump for ever

;mov ah, 0x0e            ; int 10/ah = 0eh -> scrolling teletype BIOS routine
;mov al, [os_name]       ; Set the low byte to the contents of the stored string.
;int 0x10                ; Fire BIOS screen interrupt ( with 0x0e + [the_secret] )

;jmp $                   ; Jump endlessly to this line.

;os_name:                ; An label that points to the addess where the OS name string is stored.
;db "stendex OS", 0      ; Store the OS name string into memory (db -> Declare Bytes)

times  510-($-$$) db 0  ; When compiled, our program must fit into 512 bytes, with the last two bytes being
                        ; the magic number, so here, tell our assembly compiler to pad out our program with
                        ; enough  zero  bytes (db 0) to bring us to the 510th byte.

dw 0xaa55               ; Last two bytes (one  word) form the  magic number, so BIOS knows we are a boot sector.
;je   target   ; jump if equal                     (i.e. x == y)
;jne  target   ; jump if not  equal                (i.e. x != y)
;jl   target   ; jump if less  than                (i.e. x < y)
;jle  target   ; jump if less  than or  equal     (i.e. x  <= y)
;jg   target   ; jump if  greater  than            (i.e. x > y)
;jge  target   ; jump if  greater  than or  equal (i.e. x  >= y)