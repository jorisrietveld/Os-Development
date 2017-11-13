;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This file contains an simple "Hello World" bootloader written in the NASM assembler.
;   It is able to print the hello world characters to the screen.
;

bits    16          ; Tell NASM this is 16 bit code.
org     0x7C00      ; tell MASM to start outputting stuff at ofset 0x7c00
boot:
    mov si, hello   ; Move content from hello to the source index register, so it can be used to stream to the sceen.
    mov ah, 0x0E    ; Set accumilator register to 0x0E (Ascii controll code: Shift Out, SO)
loop:
    lodsb           ;
    or al, al       ; Is 