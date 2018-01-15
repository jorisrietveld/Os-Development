;_________________________________________________________________________________________________________________________/ kernel.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 27-12-2017 19:22
;   
;   Description:
;   A simple 32 bit kernel.
;
org 0x100000
bits 32

jmp stage3

%include "library/vga/tmode_printing.asm"
%include "include/fancy_headers.asm"

stage3:
    mov ax, 0x10                ; Set the segments to 0x10
    mov ds, ax                  ; Move the data segment to 0x10
    mov ss, ax                  ; Move the stack segment to 0x10
    mov es, ax                  ; Move the extra segment to 0x10
    mov esp, 0x90000         ; The stack will start from address 0x900000 (Growing downwards)

showMenu:
    ; Print welcome message from 32 bit kernel.
    call clearDisplay         ; Clean up the screen.

    setColor VGA_WHITE, VGA_RED
    mov ebx, msgFancyHeader         ; Get the pointer to the string as argument for the printString32 call.
    call printString          ; Print the sting to the screen.

    setColor VGA_BLACK, VGA_LIGHT_BROWN
    call printString

    setColor VGA_WHITE, VGA_GREEN
    call printString

    ; Perform my favorite way to spend time.
    cli
    hlt

