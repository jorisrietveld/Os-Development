;
; Author: Joris Rietveld <jorisrietveld@gmail.com>
; Created: 09-12-2017 14:13
; Licence: GPLv3 General Public Licence version 3
;
; Description:
; This file is part of my operating system project. This file contains commonly used macro's for string manipulation.
;

%ifndef MACROS_STR_UTIL
%define MACROS_STR_UTIL

; print     -   print {message}
;==================================================================
; This macro prints a string to the screen.
%macro print 1
    push  si         ; save off
    mov si, %1

    .print_char:  ; Print a string to the screen function.
        lodsb           ; Get byte from the segment index register.
        or al, al       ; logical or on al register, are there we done printing characters?
        jz .return      ; Then return to the main routine.

        mov ah, 0x0E    ; Otherwise fetch an new character.
        int 0x10        ; And print the character to the screen with an BIOS interrupt.
        jmp .print_char ; Go the the next character.

    .return:
        pop si  ;
        ret    ; Back to main routine.
%endmacro

; println   -   println {message}
;==================================================================
; This macro prints a string and moves the caret to the next line.
%macro println 1
    push  si         ; save off
       mov si, %1

       .print_char:  ; Print a string to the screen function.
           lodsb           ; Get byte from the segment index register.
           or al, al       ; logical or on al register, are there we done printing characters?
           jz .return      ; Then return to the main routine.

           mov ah, 0x0E    ; Otherwise fetch an new character.
           int 0x10        ; And print the character to the screen with an BIOS interrupt.
           jmp .print_char ; Go the the next character.

       .return:
           mov ah, 0x0E    ; Otherwise fetch an new character.
           mov al, 0x0D
           int 0x10        ; And print the character to the screen with an BIOS interrupt.
           mov al, 0x0A
           int 0x10        ; And print the character to the screen with an BIOS interrupt.

           pop si  ;
           ret    ; Back to main routine.
%endmacro

; defstr        -   defstr {label} {string}
;==================================================================
; This macro defines a zero terminated string.
%macro defstr 2
  jmp %1_after_def    ; jump over the string that we define
  %1 db %2, 0         ; declare the string
  %1_after_def:       ; continue on
%endmacro

%endif
