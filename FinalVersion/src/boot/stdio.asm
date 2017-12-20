;                                                                                       ,   ,           ( VERSION 0.0.2
;                                                                                         $,  $,     ,   `̅̅̅̅̅̅( 0x002
;                                                                                         "ss.$ss. .s'          `̅̅̅̅̅̅
;   MMMMMMMM""M MMP"""""YMM MM"""""""`MM M""M M""MMMM""M                          ,     .ss$$$$$$$$$$s,
;   MMMMMMMM  M M' .mmm. `M MM  mmmm,  M M  M M  `MM'  M                          $. s$$$$$$$$$$$$$$`$$Ss
;   MMMMMMMM  M M  MMMMM  M M'        .M M  M MM.    .MM    .d8888b. .d8888b.     "$$$$$$$$$$$$$$$$$$o$$$       ,
;   MMMMMMMM  M M  MMMMM  M MM  MMMb. "M M  M M  .mm.  M    88'  `88 Y8ooooo.    s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
;   M. `MMM' .M M. `MMM' .M MM  MMMMM  M M  M M  MMMM  M    88.  .88       88   s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
;   MM.     .MM MMb     dMM MM  MMMMM  M M  M M  MMMM  M    `88888P' `88888P'   s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
;   MMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMMM MMMM MMMMMMMMMM                       s$$$$$$$$$$'         `"""ss"$"$s""
;                                                                               s$$$$$$$$$$,              `"""""$  .s$$s
;   ______[  Author ]______    ______[  Contact ]_______                        s$$$$$$$$$$$$s,...               `s$$'  `
;      Joris Rietveld           jorisrietveld@gmail.com                       sss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
;                                                                             `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
;   _______________[ Website & Source  ]________________                           "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
;       https://github.com/jorisrietveld/Bootloaders                                 "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
;                                                                                     $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
;   ___________________[ Licence ]______________________                             $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
;             General Public licence version 3                                  ,   ,"     '  $$$$$$$$$$$$$$$$####s
;   ===============================================================================================================    ;
;                                                                                       standard 16 bits I/O macros    ;                                                                                                                     ;
;   Description:                                                                        ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅    ;
;   This file includes several assembler macros for standard input and output operations in 16 bits mode. Like         ;
;   string printing operations keyboard input etc.                                                                     ;
;   Created: 20-12-2017 07:25                                                                                          ;
;                                                                                                                      ;
%ifndef STD_IO_16
%define STD_IO_16

bits 16

;_________________________________________________________________________________________________________________________/ ϝ print
;   This function prints a string to the screen.
%macro print 1
    pusha       ; Save the CPU register state to the stack.
    mov si, %1  ; Set the source pointer to the start of the string to print.

    .print_char:  ; Print a string to the screen function.
        lodsb           ; Get byte from the segment index register.
        or al, al       ; logical or on al register, are there we done printing characters?
        jz .return      ; Then return to the main routine.

        mov ah, 0x0E    ; Otherwise fetch an new character.
        int 0x10        ; And print the character to the screen with an BIOS interrupt.
        jmp .print_char ; Go the the next character.

    .return:
        popa    ; restore the CPU registers from the stack.
        ret     ; Back to main routine.
%endmacro

;_________________________________________________________________________________________________________________________/ ϝ println
;   This function prints a string to the screen and moves the cursor to a new line.
%macro println 1
    pusha       ; Save the CPU register state to the stack.
    mov si, %1  ; Set the source pointer to the start of the string to print.

    .print_char:  ; Print a string to the screen function.
        lodsb           ; Get byte from the segment index register.
        or al, al       ; logical or on al register, are there we done printing characters?
        jz .print_nl    ; Then return to the main routine.

        mov ah, 0x0E    ; Load an shift out character.
        int 0x10        ; And print the character to the screen with an BIOS interrupt.
        jmp .print_char ; Go the the next character.

    .print_nl:
        mov ax, 0x0E0D   ; Set ascii shift out character + Set ascii carriage return character.
        int 0x10        ; And print the character to the screen with an BIOS interrupt.
        mov al, 0x0A    ; Set ascii new line feed character.
        int 0x10        ; And print the character to the screen with an BIOS interrupt.
        jmp .return     ; Done, so return.

    .return:
        popa    ; restore the CPU registers from the stack.
        ret     ; Back to main routine.
%endmacro

;_________________________________________________________________________________________________________________________/ ϝ defstr
;   This function creates an new zero terminated string.
%macro defstr 2
  jmp %1_after_def    ; jump over the string that we define
  %1 db %2, 0         ; declare the string
  %1_after_def:       ; continue on
%endmacro

%endif
