;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   Hello friend, start the hack of the century...
;
bits    16                  ; Configure NASM for Real Mode.
org     0x7C00              ; Set program offset at 0x7C00.

initaite:; Initiate the program
    mov ax, 0               ; Initiate the accumulator register with 0.
    mov ds, ax              ; Initiate data segment register with 0.
    mov es, ax              ; Initiate extra segment register with 0.
    mov ss, ax              ; Initiate stack segment register with 0.
    mov sp, 0x7C00          ; Point the top of the stack at address 0x7C00.

    mov si, header_str      ; Fetch header string into the segment index register.
    call write_string_func  ; Print the register content to the screen.

;====================================================================================[ MAIN ROUTINE ]=-
main_routine:;Wait for society reboot
    mov si, prompt_str      ; Fetch input prompt string into the segment index register.
    call write_string_func  ; Print the register to the screen.

    mov di, input_buffer    ; Set input buffer to the destination index for reading.
    call read_string_func   ; Read characters into the buffer.

    mov si, input_buffer    ; Fetch the input buffer contents to the source index.
    cmp byte [si], 0        ; Is the buffer currently empty?
    je main_routine         ; Then keep waiting for user input.

   ; Otherwise check if we understand the command.
    mov si, input_buffer    ; Fetch the input buffer contents to the source index register.
    mov di, cmd_rtc_str     ; Fetch the RTC command to the data index register
    call string_compare     ; Compare source with data, are they equal?
    jc .rtc_routine         ; Then jump to the RTC routine.

    ; Otherwise compare next command.
    mov si, input_buffer    ; Fetch the input buffer contents to the source index register.
    mov di, cmd_aes_str     ; Fetch the AES command to the data index register
    call string_compare     ; Compare source with data, are they equal?
    jc .aes_routine         ; Then jump to the AES routine.

    ; Other wise the dark army wont cooperate.
    mov si, msg_error_str   ; Fetch the bad news to the source index register.
    call write_string_func  ; Print the bad news to the screen.
    jmp main_routine        ; Try to contact the dark army again.

;====================================================================================[ RTC ROUTINE ]=-
.rtc_routine:;#OP steel mountain
    mov si, msg_rtc_str     ; Fetch the RTC message to the source index register.
    call write_string_func  ; Output the buffer to the screen.
    jmp main_routine        ; Finished printing, go back to the main routine.

;====================================================================================[ AES ROUTINE ]=-
.aes_routine:;Encrypt E corp
    mov si, msg_aes_str     ; Fetch the AES message to the source index register.
    call write_string_func  ; Output the buffer to the screen.
    jmp main_routine        ; Finished printing, go back to the main routine.

;===============================================================================[ STRING CONSTANTS ]=-
header_str db '-------------{ FSOCIETY OS }-------------', 0x0D, 0x0A, 0
menu_opt1_str db '[1] - Send 3Li0t an message over RTC'
menu_opt2_str db '[2] - Steal mountain is ready call in the dark army'
msg_rtc_str db 'hello friend...', 0x0D, 0x0A, 0
msg_error_str db 'The dark army is out...', 0x0D, 0x0A, 0
prompt_str db '>', 0
cmd_rtc_str db '1', 0
cmd_aes_str db '2', 0
msg_aes_str db '[AES 256] - encrypting files...', 0x0D, 0x0A, 0
input_buffer times 64 db 0    ; Fill the buffer with zeros

;===========================================================================[ WRITE STRING ROUTINE ]=-
write_string_func:  ; Print a string to the screen function.
    lodsb           ; Get byte from the segment index register.
    or al, al       ; logical or on al register, are there we done printing characters?
    jz .return      ; Then return to the main routine.
    mov ah, 0x0E    ; Set the high bit to shift out operation.
    int 0x10        ; And print the character to the screen with an BIOS interrupt.
    jmp write_string_func ; Go the the next character.
    .return: ret    ; Back to main routine.


;============================================================================[ READ STRING ROUTINE ]=-
read_string_func: ; Read key presses from the user.
    xor cl, cl      ;

.loop:
    mov ah, 0
    int 0x16        ; Wait for key press.

    cmp al, 0x80    ; Backspace pressed?
    je .back_key    ; Handle the backspace key, it will remove the last char.

    cmp al, 0x0D    ; Enter pressed?
    je .enter_key   ; Were done reading input. go back to the main routine.

    cmp cl, 0x3F    ; Are there 63 characters in the I/O input?
    je .loop        ; Then only allow backspaces or enters

    mov ah, 0x0E    ;
    int 0x10        ; Print the entered character to the screen

    stosb           ; Put the character in the buffer
    inc cl          ;
    jmp .loop       ;

;================================================================================[ BACKSPACE EVENT ]=-
.back_key:;Handle Backspace key
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
;===================================================================================[ ENTER EVENT ]=-
.enter_key:; Handle enter key
    mov al, 0       ; Set an null terminator to the register.
    stosb           ; Append the terminator to the end of the string.

    mov ah, 0x0E    ; Reset accumulator high byte.
    mov al, 0x0D    ; Reset accumulator high byte.
    int 0x10
    mov al, 0x0A    ; Set an newline character to the register.
    int 0x10        ; Insert the newline character
    ret             ; Return to main routine.

;=========================================================================[ STRING COMPARE ROUTINE ]=-
string_compare:;Compare strings in source and data register
.compare:
    mov al, [si]    ; Load an byte from the source index register.
    mov bl, [di]    ; Load an byte from the data index register.
    cmp al, bl      ; Compare the 2 registers, are they different?
    jne .return_false; Then call not equal to set the cary flag to false.

    cmp al, 0       ; are both byes null?
    je .return_true ; Then we're done comparing the strings.

    inc di          ; Increment the data index
    inc si          ; Increment the source index
    jmp .compare    ; Go to the next character to compare in the string.

.return_false:
    clc             ; The strings are not the same, set the cary flag to false.
    ret             ; return to main routine.

.return_true:
    stc             ; The strings are the same, set the cary flag to true.
    ret             ; return to main routine.

times 510-($-$$) db 0 ; fill the rest of the sector with the amount of money on my bank account.
dw 0xAA55 ; Mark this sector (the 512 bytes used in the bootloader) as bootable with black magic.

