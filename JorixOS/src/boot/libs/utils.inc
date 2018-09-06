;__________________________________________________________________________________________/ utils.inc
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 03-06-2018 02:59
;   
;   Description:
;   This file contains utility functions for printing and user input.
[bits 16]

%ifndef __UTILS_INC_INCLUDED__
%define __UTILS_INC_INCLUDED__

;%include 'intel16/ascii.inc'
;%include 'intel16/bios.inc'
;%include 'intel16/jorix_debug.inc'
%include 'libs/common.inc'

NEWLINE db 0x0A, 0x0D, 0                ; Ascii control codes for a newline: Carriage Return, Line Feed and Null.

;_________________________________________________________________________________________________________________________/ ϝ print_16
;   Description:
;   This macro prints a null terminated character array to the screen.
;
;   Function Arguments:
;   1       An pointer to an null terminated character array.
;
;   Returns:
;   -
%macro print_16 1
    mov si, word %1                     ; Get the pointer passed to this macro and put it into the source index.
    call decl_print_16                  ; Call the function that prints the characters to the screen.
%endmacro ; print_16

;_________________________________________________________________________________________________________________________/ ϝ newline_16
;   Description:
;   This macro moves the cursor to an new line.
;
%macro newline_16 0
    print_16 NEWLINE                    ;
%endmacro

;_________________________________________________________________________________________________________________________/ ϝ println_16
;   Description:
;   This macro prints a null terminated character array to the screen and moves the cursor to the next line.
;
;   Function Arguments:
;   1       An pointer to an null terminated character array.
;
%macro println_16 1
    mov si, word %1                     ; Get the pointer passed to this macro and put it into the source index.
    call decl_print_16                  ; Call the function that prints the characters to the screen.
    newline_16                          ; After printing the string, move the cursor to the start of a new line.
%endmacro

;_________________________________________________________________________________________________________________________/ ϝ decl_print_16
;   Description:
;   This function will print a null terminated character array to the screen. This is the underlying assembly code that
;   the print_16, newline_16 and println_16 macros use.
;
;   Function Arguments:
;   si      An pointer pointing to the first element of the character array.
;
decl_print_16:
    ; Print each character until an null byte is reached.
    .charLoop:
        lodsb                           ; Load a byte from the data segment that is pointed to by the si argument to al.
        or al, al                       ; Check the byte for a null, using an OR that sets the zero flag on a null.
        jz .done                        ; Null reached? done
        mov ah, ASCII_CRTL_SO           ; Prepare the interrupt to Shift Out the character to the screen.
        int BIOS_INTERRUPT_VIDEO          ; Execute the interrupt.
        jmp .charLoop                   ; Loop through the rest of the string.
    ; Null byte reached done printing.
    .done:
        ret                             ; Return to the caller.

%endif ; __UTILS_INC_INCLUDED__
