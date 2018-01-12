;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   A simple bootloader that shows an menu and and allows the user to choose an option from the menu.
;
bits    16                  ; Configure NASM for Real Mode.
org     0x7C00              ; Set program output offset at 0x7C00.

initaite:; Initiate the program
    mov ax, 0               ; Initiate the accumulator register with 0.
    mov ds, ax              ; Initiate data segment register with 0.
    mov es, ax              ; Initiate extra segment register with 0.
    mov ss, ax              ; Initiate stack segment register with 0.
    mov sp, 0x7C00          ; Point the top of the stack at address 0x7C00.

    mov si, HEADER1_STR      ; Fetch header string into the segment index register.
    call print_string       ; Print the register content to the screen.

    mov si, HEADER_STR      ; Fetch header string into the segment index register.
    call print_string       ; Print the register content to the screen.

    mov si, HEADER1_STR      ; Fetch header string into the segment index register.
    call print_string       ; Print the register content to the screen.

    mov si, MENU_OPT1_STR   ; Fetch menu option 1 string into the segment index register.
    call print_string       ; Print the register content to the screen.
    mov si, MENU_OPT2_STR   ; Fetch menu option 2 string into the segment index register.
    call print_string       ; Print the register content to the screen.

;====================================================================================[ MAIN ROUTINE ]=-
main_routine:
    mov si, PROMT_CHAR      ; Fetch input prompt string into the segment index register.
    call print_string       ; Print the register to the screen.

    mov di, input_buffer    ; Set input buffer to the destination index for reading.
    call read_string        ; Read characters into the buffer.

    mov si, input_buffer    ; Fetch the input buffer contents to the source index.
    cmp byte [si], 0        ; Is the buffer currently empty?
    je main_routine         ; Then keep waiting for user input.

   ; Otherwise check if we understand the command.
    mov si, input_buffer    ; Fetch the input buffer contents to the source index register.
    mov di, CMD_BOOT        ; Fetch the boot command to the data index register
    call string_compare     ; Compare source with data, are they equal?
    jc .boot_routine        ; Then jump to the boot routine.

   ; Otherwise check if we understand the command.
    mov si, input_buffer    ; Fetch the input buffer contents to the source index register.
    mov di, CMD_HELP        ; Fetch the help command to the data index register
    call string_compare     ; Compare source with data, are they equal?
    jc .help_routine        ; Then jump to the help routine.

    ; Otherwise compare next command.
    mov si, input_buffer    ; Fetch the input buffer contents to the source index register.
    mov di, CMD_SHUTDOWN    ; Fetch the shutdown command to the data index register
    call string_compare     ; Compare source with data, are they equal?
    jc .shutdown_routine    ; Then jump to the shutdown routine.

    ; Other wise the dark army wont cooperate.
    mov si, MSG_ERROR       ; Fetch the bad news to the source index register.
    call print_string       ; Print the bad news to the screen.
    jmp main_routine        ; Try to contact the dark army again.

;==================================================================================[ Boot function ]=-
.boot_routine:
    mov si, MSG_BOOTING     ; Fetch the boot message to the source index register.
    call print_string       ; Output the buffer to the screen.
    jmp main_routine        ; Finished printing, go back to the main routine.

;==================================================================================[ Help function ]=-
.help_routine:
    mov si, MENU_OPT1_STR   ; Fetch first menu option to the source index register.
    call print_string       ; Output the buffer to the screen.
    mov si, MENU_OPT2_STR   ; Fetch second menu option to the source index register.
    call print_string       ; Output the buffer to the screen.
    jmp main_routine        ; Finished printing, go back to the main routine.

;==============================================================================[ Shutdown function ]=-
.shutdown_routine:
    mov si, MSG_SHUTDOWN     ; Fetch the AES message to the source index register.
    call print_string  ; Output the buffer to the screen.
    jmp main_routine        ; Finished printing, go back to the main routine.

;===============================================================================[ STRING CONSTANTS ]=-
; The 0x0D means carriage ret in ascii ( Go back to start of line )
; The 0x0A means line feed in ascii ( Scroll down )
; The 0x00 means NULL in ascii (string terminator)
HEADER1_STR db '========================================', 0x0D, 0x0A, 0x00
HEADER_STR db '-------------{ STENDEX OS }-------------', 0x0D, 0x0A, 0x00
MENU_OPT1_STR db '[boot] - Boot stendex kernel',0x0D, 0x0A, 0x00
MENU_OPT2_STR db '[shutdown] - Shutdown the computter',0x0D, 0x0A,  0x00
MSG_BOOTING db 'Booting stendex', 0x0D, 0x0D, 0x0A,  0x00
MSG_ERROR db 'unrecognized command', 0x0D, 0x0A,  0x00
MSG_SHUTDOWN db 'Shutting down',0x0D, 0x0D, 0x0A,  0x00
PROMT_CHAR db '>',  0x00
CMD_BOOT db 'boot',  0x00
CMD_HELP db 'help',  0x00
CMD_SHUTDOWN db 'shutdown',  0x00

input_buffer times 10 db 0    ; Fill the buffer with zeros

%include "print_string.asm"
%include "read_string.asm"
%include "compare_string.asm"

times 510-($-$$) db 0 ; Pad the rest of the first boot sector with zeros.
dw 0xAA55 ; Mark this sector as bootable with black magic.

