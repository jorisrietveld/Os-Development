;__________________________________________________________________________________________/ kernel.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 27-12-2017 19:22
;   
;   Description:
;
org 0x10000
bits 32

jmp stage3

%include "./libs/stdio.asm"

msg db 0x0A, 0x0A, "Welcome to the Jorix OS kernel", 0x0A, 0

stage3:
    mov ax, 0x010
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000

    call clearScreen32
    mov ebx, msg
    call printString32

    cli
    hlt
