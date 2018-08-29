;_________________________________________________________________________________________________________________________/ kernel.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 27-12-2017 19:22
;   
;   Description:
;   A simple 32 bit kernel.
;
org 0x10000
bits 32

jmp stage3

%include "./lib/stdio.asm"

msg db 0x0A, 0x0A, "Welcome to the Jorix OS kernel", 0x0A, 0

stage3:
    mov ax, 0x010       ; Set the segments to 0x10
    mov ds, ax          ;
    mov ss, ax          ;
    mov es, ax          ;
    mov esp, 0x90000    ; The stack will start from address 0x900000 (Growing downwards)

    ; Print welcome message from 32 bit kernel.
    call clearDisplay32  ; Clean up the screen.
    mov ebx, msg        ; Get the pointer to the string as argument for the printString32 call.
    call printString32  ; Print the sting to the screen.

    ; Perform my favorite way to spend time.
    cli
    hlt
