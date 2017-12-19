;                                                                                       ,   ,           ( VERSION 0.0.1
;                                                                                         $,  $,     ,   `̅̅̅̅̅̅( 0x001
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
;                                                                                            First Stage Bootloader    ;                                                                                                                     ;
;   Description:                                                                             ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅    ;
;   This file contains the second stage of the bootloader. Because of the memory size constrains of only 512 bytes,    ;
;   we have split the bootloader into two stages. One for setting up the minimal requirements of the system and a      ;
;   second one that can switch the CPU into protected mode and knows how to locate and start the operating system.     ;
;   This file contains the second stage that is responsible for loading the kernel. It contains both 16 bit and 32     ;
;   bit assembler code because it will switch the CPU from 16 bit (Keep it) real mode to 32 bit protected mode.        ;
;
;   _______C______________[ File  ]________________                                     ;
;   Created: 13-11-2017 21:40   Altered: 11-12-2017 20:11
;
;
;   Description:
;   This file contains the second stage of the bootloader. This code gets
;   executed by the fist stage bootloader located in the first sector of the
;   disk. This stage of the bootloader is responsible for loading the kernel
;   of Jorix OS.
;
org 0x00    ; Offset to address 0
bits 16     ; Assemble to 16 bit instructions (For 16 bit real-mode)
jmp main    ; Jump to the main label.

;
; Prints a string to the screen.
;
print:
    pusha   ; Save the current state of the CPU registers to the stack.

    .print_character:   ; Routine to load and print a character.
        lodsb       ; Load 1 byte from the source index to ax low register (al), so we can print it with an bios interrupt.
        or al, al   ; Check if the ax low contains an 0 byte, if so the zero flag gets set by the or operation.
                    ; Remember that we use an 0 byte to terminate a string, so if al contains a 0 it means the end of a string.
        jz .return  ; Jump to the return routine if the zero flag is set.
        mov ah, 0x0E; Set the ax high byte to the ASCII Control: shift out character, this is the function the BIOS interrupt executes.
        int 0x10    ; Fire an BIOS video service interrupt that takes ah as function and al as argument. So it will print al to the screen.
        jmp .print_character ; Jump back to the top to load and print the next character.

    .return:    ; When all characters of the string are printed restore the CPU registers and return to caller.
        popa    ; Restore the registers to the previous state (that we stored on the stack)
        ret     ; Return to the caller of this function.
;
; This is the entry point of the second stage bootloader.
;
main:
    cli     ; clear the interrupts
    push cs ; DS=CS
    pop ds  ;

    mov si, message ; Move the address of the welcome message to the source index register.
    call print      ; Print the stored message to the screen.
    cli     ; Clear the interrupts.
    hlt     ; Halt the execution.
;
; Some string constants.
; Info:
; 0x0D is the ASCII Control CR (Carriage Return) character, this moves the carriage to the beginning of the line.
; 0x0A is the ASCII Control NL (New Line feed) character, this moves the carriage to the next line.
;
message: db "Preparing to load the Jorix OS...", 0x0D, 0x0A, 0 ;
;__________________________________________________________________________________________/ stage2.asm.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 18-12-2017 15:47
;   
;   Description:
;
