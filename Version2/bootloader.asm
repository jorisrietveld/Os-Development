;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This file contains an simple "Hello World" bootloader written in the NASM assembler.
;   It is able to print the hello world characters to the screen.
;

bits    16          ; Tell NASM the output should be in 16 bit instructions ( Real Mode ).
org     0x7C00      ; Tell MASM the output should start writing at register offset 0x7C00.

; Initiate the program
boot:
    mov ax, 0       ; Initiate the segments.
    mov ds, ax      ;
    mov es, ax      ;
    mov ss, ax      ; Setup stack segment register
    mov sp, 0x7C00  ; The stack grows downwards from 0x7C00

    mov si, welcome     ; Set segment index to welcome function.
    call print_string   ; Print the contents inside the segment index.

mainloop:
    mov si, prompt      ; Set segment index to prompt function
    call print_string   ; Call print_string function that prints the si contents.

    mov di, buffer      ; Set the data index to the buffer function
    call get_string     ; Call the get string function to start listening for user input.


    mov si, buffer      ; Copy the contents of the I/O input buffer to the segment index.
    cmp byte [si], 0    ; Is the buffer currently empty?
    je mainloop         ; The buffer is empty, keep waiting for user input.

    mov si, buffer      ; Set the segment index to the I/O buffer.
    mov di, cmd_hi      ; Get the hi command to the data register
    call strcmp         ; Check if the user input equals the hi command.
    jc .helloworld      ; The command maches so call the print hi function.

    ; The command didn't match hi so check for the next command.
    mov si, buffer      ; set the segment index to the I/O buffer.
    mov di, cmd_help    ; Get the help command to the data register.
    call strcmp         ; Check if the user input equals the help command.
    jc .help            ; The command maches so call the print help function.

    ; The command wasn't recognized, inform user and go back the main loop.
    mov si, badcommand  ; Move the bad command messsage into the segment index.
    call print_string   ; Print the error message to the users screen.
    jmp mainloop        ; Let the user try it again.

; The hello world function, it prints hello world to the screen.
.helloworld:
    mov si, msg_helloworld  ; Load the output buffer with the hello world string.
    call print_string       ; Output the buffer to the screen.
    jmp mainloop            ; Finished printing, go back to the main routine.

; The help function, it prints the help string to the screen.
.help:
    mov si, msg_help    ; Load the output buffer with the help string.
    call print_string   ; Output the buffer to the screen.
    jmp mainloop        ; Finished printing, go back to the main routine.

welcome db 'Welcome to FSOCIETY OS', 0x0D, 0x0A, 0
msg_helloworld db 'hello friend...', 0x0D, 0x0D, 0x0A, 0
badcommand db 'You entered an unrecognized option', 0x0D, 0x0A, 0
prompt db '>', 0
cmd_hi db 'hi', 0
cmd_help db 'help', 0
msg_help db 'We contacted the dark army to support you', 0x0D, 0x0A, 0
buffer times 64 db 0    ; Fill the buffer with zeros

; Print a string to the screen function.
print_string:
    lodsb   ; Get byte from the segment index register.

    or al, al   ; logical or on the arithmetic low regiser.
    jz .done    ; If the al is empty were done printing the string.

    ; There are characters left to print
    mov ah, 0x0E    ;
    int 0x10        ; print the character to the screen with an BIOS interrupt.

    jmp print_string ; Go the the next character.

    .done:
        ret         ; return

; Read key pesses from the user.
get_string:
    xor cl, cl      ;

.loop:
    mov ah, 0
    int 0x16    ; Wait for key press.

    cmp al, 0x80    ; Backspace pressed?
    je .backspace   ; Handle the backspace key, it will remove the last char.

    cmp al, 0x0D    ; Enter pressed?
    je .done        ; Were done reading input. go back to the main routine.

    cmp cl, 0x3F    ;


dw 0xAA55 ; Mark this sector (the 512 bytes used in the bootleader) as bootable with the magic constand.