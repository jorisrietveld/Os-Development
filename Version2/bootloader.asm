;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This program prints an menu to the screen where the user can input stuff.

bits    16          ; Tell NASM the output should be in 16 bit instructions ( Real Mode ).
org     0x7C00      ; Tell NASM the output should start writing at register offset 0x7C00.

; Initiate the program
initaite:
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


    mov si, buffer      ; Copy the contents of the buffer to the source index register.
    cmp byte [si], 0    ; Is the buffer currently empty?
    je mainloop         ; The buffer is empty, keep waiting for user input.

    mov si, buffer      ; Set the source index to the I/O buffer.
    mov di, cmd_hi      ; Get the hi command to the data register
    call strcmp         ; Check if the user input equals the hi command.
    jc .helloworld      ; The command matches so call the print hi function.

    ; The command didn't match hi so check for the next command.
    mov si, buffer      ; set the segment index to the I/O buffer.
    mov di, cmd_help    ; Get the help command to the data register.
    call strcmp         ; Check if the user input equals the help command.
    jc .help            ; The command matches so call the print help function.

    ; The command wasn't recognized, inform user and go back the main loop.
    mov si, badcommand  ; Move the bad command message into the segment index.
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

welcome db '-------------{ FSOCIETY OS }-------------', 0x0D, 0x0A, 0
option1 db '[1] - Send 3Li0t an message over RTC'
option2 db '[2] - Steal mountain is ready call in the dark army'
msg_helloworld db 'hello friend...', 0x0D, 0x0D, 0x0A, 0
badcommand db 'bad command', 0x0D, 0x0A, 0
prompt db '>', 0
cmd_hi db '1', 0
cmd_help db '2', 0
msg_help db '[AES 256] - encrypting files...', 0x0D, 0x0A, 0
buffer times 64 db 0    ; Fill the buffer with zeros


; Print a string to the screen function.
print_string:
    lodsb   ; Get byte from the segment index register.

    or al, al   ; logical or on the arithmetic low register.
    jz .done    ; If the al is empty were done printing the string.

    ; There are characters left to print
    mov ah, 0x0E    ;
    int 0x10        ; print the character to the screen with an BIOS interrupt.

    jmp print_string ; Go the the next character.

    .done:
        ret         ; return

; Read key presses from the user.
get_string:
    xor cl, cl      ;

.loop:
    mov ah, 0
    int 0x16    ; Wait for key press.

    cmp al, 0x80    ; Backspace pressed?
    je .backspace   ; Handle the backspace key, it will remove the last char.

    cmp al, 0x0D    ; Enter pressed?
    je .done        ; Were done reading input. go back to the main routine.

    cmp cl, 0x3F    ; Are there 63 characters in the I/O input?
    je .loop        ; Then only allow backspaces or enters

    mov ah, 0x0E    ;
    int 0x10        ; Print the entered character to the screen

    stosb           ; Put the character in the buffer
    inc cl          ;
    jmp .loop       ;

.backspace:
    cmp cl, 0       ; Is it the beginning of the string?
    je .loop        ; Then ignore the the key

    dec di          ; Move back 1 in the string
    mov byte[di], 0 ; Overwrite the char with 0, so the character gets deleted.
    dec cl          ; Also decrement the string length counter.

    mov ah, 0x0E    ;
    mov al, 0x08    ;
    int 10h         ; Backspace on the screen

    mov al, ' '     ; Set an empty space in the buffer.
    int 10h         ; Write the empty space over the character.

    mov al, 0x08    ;
    int 10h         ; Backspace again

    jmp .loop       ; Go to the main loop of the input read function.

.done:
    mov al, 0       ; Set an null terminator to the register.
    stosb           ; Append the terminator to the end of the string.

    mov ah, 0x0E    ;
    mov al, 0x0D    ;
    int 0x10
    mov al, 0x0A    ; Set an newline character to the register.
    int 0x10        ; Insert the newline character

    ret             ; Return

strcmp:
.loop:
    mov al, [si]    ; Load an byte from the source index register.
    mov bl, [di]    ; Load an byte from the data index register.
    cmp al, bl      ; Compare the 2 registers, are they different?
    jne .notequal   ; Then call not equal to set the cary flag to false.

    cmp al, 0       ; are both byes null?
    je .done        ; Then we're done comparing the strings.

    inc di          ; Increment the data index
    inc si          ; Increment the source index
    jmp .loop       ; Go to the next character to compare in the string.

.notequal:
    clc             ; The strings are not the same, set the cary flag to false.
    ret             ; Return to the main program routine.

.done:
    stc             ; The strings are the same, set the cary flag to true.
    ret             ; Return to the main program routine.

times 510-($-$$) db 0 ; fill the rest of the sector with the amount of money on my bank account.
dw 0xAA55 ; Mark this sector (the 512 bytes used in the bootloader) as bootable with black magic.

