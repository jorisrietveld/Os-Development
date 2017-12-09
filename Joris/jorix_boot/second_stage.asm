;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
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
