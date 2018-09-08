;_________________________________________________________________________________________________________________________/ kernel.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 27-12-2017 19:22
;   
;   Description:
;   A simple 32 bit kernel.
;
org 0x100000
bits 32

jmp kernelASM

%include "lib/stdio.asm"
;%include "lib/fancy_headers.asm"


;msgWelcome db 0x0A, 0x0A, "Welcome to the Jorix OS kernel", 0x0A, 0

;%define STACK_BASE 0x90000

kernelASM:
    mov ax, 0x10                ; Set the segments to 0x10
    mov ds, ax                  ; Move the data segment to 0x10
    mov ss, ax                  ; Move the stack segment to 0x10
    mov es, ax                  ; Move the extra segment to 0x10
    mov esp, 0x90000            ; The stack will start from address 0x900000 (Growing downwards)

    ; Print welcome message from 32 bit kernel.
    call clearDisplay32         ; Clean up the screen.

    ;mov ebx, msgWelcome         ; Get the pointer to the string as argument for the printString32 call.
    call printString32          ; Print the sting to the screen.

    ; Perform my favorite way to spend time.
    cli
    hlt

;msgFancyHeader:
;db '  __ \ \  \ \  \\\  \ \   _  _\ \  \  \ \    / /      \ \  \\\  \ \_____  \     ', 0x0A
;db ' |\  \\_\  \ \  \\\  \ \  \\  \\ \  \  /     \/        \ \  \\\  \|____|\  \    ', 0x0A
;db ' \ \________\ \_______\ \__\\ _\\ \__\/  /\   \         \ \_______\____\_\  \   ', 0x0A
;db '  \|________|\|_______|\|__|\|__|\|__/__/ /\ __\         \|_______|\_________\  ', 0x0A
;db 0x00 ; NULL byte string terminator.