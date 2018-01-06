;_________________________________________________________________________________________________________________________/ Stage2.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 20-12-2017 07:25
;
;   Description:
;   This file includes several assembler macros for standard input and output operations in 16 bits mode. Like
;   string printing operations keyboard input etc.
;
%ifndef __STDIO_ASM_INCLUDED__
%define __STDIO_ASM_INCLUDED__
bits 16

%define DISPLAY_BIOS_INT    0x10    ; Bios interrupt for low level display services.

%define ASCII_SO_CHAR       0x0E    ; Ascii new line feed character.
%define ASCII_LF_CHAR       0x0A    ; Ascii new line feed character.

;_________________________________________________________________________________________________________________________/ ϝ put_string_16
;   Description:
;   This function prints a string to the screen using BIOS interrupts.
printString16:
	pusha				; save registers

    .print_char:
		lodsb                   ; load next byte from string from SI to AL
		or	al, al              ; Does AL=0?
		jz	.return		        ; Yep, null terminator found-bail out
		mov	ah, ASCII_SO_CHAR   ; Nope-Print the character
		int	DISPLAY_BIOS_INT    ; invoke BIOS
		jmp	.print_char	        ; Repeat until null terminator found

    .return:
		popa            ; restore registers
		ret	            ; we are done, so return

;_________________________________________________________________________________________________________________________/ § 32 bit IO
;   This section contains standard IO functions in 32 bits that are used when the CPU switched to Protected Mode.

bits 32
%define     VIDEO_MEMORY    0xB8000     ; The address maped to video memory in VGA mode 7.
%define     COLUMNS         80          ; The amount of columns on the screen.
%define     LINES           25          ; The amount of lines on the screen.
%define     CHAR_ATTRIBUTE  0x1F        ; The default character attribute (white char on black background)

_cursorPositionX db 0
_cursorPositionY db 0

;_________________________________________________________________________________________________________________________/ ϝ printCharacter32
;   Description:
;   This function prints a single character to the screen using direct video memory access.
;
;   Function Arguments:
;   bl      The character to print on the screen.
printCharacter32:
    pusha                           ; Save the current CPU register state.
    mov edi, VIDEO_MEMORY           ; Initiate the data input at the start of the video memory.

    ; Get the current cursor position
    xor eax, eax                    ; Reset the
    mov ecx, COLUMNS * 0x02         ; Set the column width to char width(2byte) * columns
    mov al, byte[_cursorPositionY]  ; Get the current y position of the cursor.
    mul ecx                         ; Multiply the y position by the
    push eax                        ; Save the calculated value on the stack.
    mov al, byte[_cursorPositionX]  ; Get the x position of the cursor.
    mov cl, 0x02                    ; Get the width of an char (2 bytes)
    mul cl                          ; Multiply the cursor x position by the width.
    pop ecx                         ; Push the calculated value on to the stack.
    add eax, ecx                    ; Add the character position to calculate the offset.
    xor ecx, ecx                    ; Clear the counter register.
    add edi, eax                    ; Add the offset to the base.

    ; Check for new line cha_cursorPositionY characters.
    cmp bl, ASCII_LF_CHAR           ; Do we need to print an newline character?
    je .row                         ; Yes, then jump to the newline routine.

    ; Print the character
    mov dl, bl                      ; Set the function input to the data low register.
    mov dh, CHAR_ATTRIBUTE          ; Set the character attribute to data high.
    mov word[edi], dx               ; Write the character with attributes to the video memory.

    ; Update the position
    inc byte[_cursorPositionX]      ; Increment the position x tracker.
 ;   cmp byte[_cursorPositionY], COLUMNS ; Check if we are at the end of the line.
  ;  je .row                         ; If so insert an new line feed.
    jmp .finished                   ; Else jump to the exit routine.

    ;____________ Move to an new line feed ____________
    ; This routine moves the cursor to an new line feed.
    .row:
        mov byte[_cursorPositionX], 0x00; Go back to column 0 on the new line.
        inc byte[_cursorPositionY]  ; Increment the line number.

    ;___________________________ Return ____________________________________
    ; Finished printing, restore the CPU registers and return to the caller.
    .finished:
        popa                        ; Restore the registers.
        ret                         ; Return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ printString32
;   Description:
;   This function prints a string to the screen using direct video memory access.
;
;   Function Arguments:
;   bl      The start address of the string.
printString32:
    pusha                           ; Save the CPU registers.
    push ebx                        ; Copy the string address.
    pop edi                         ; Get the data index.

    ;_____________ Character Loop iteration _______________
    ; Start iterating through each character in the string.
    .characterIteration:
        mov bl, byte[edi]           ; Get the next character.
        cmp bl, 0                   ; Does the current character contain an null termination character.
        je .finished                ; Yes, we are at the end of the string, jump to the return routine.
        call printCharacter32       ; Else print the character in dl to the screen using the printString function

    ;______ Finish the iteration, increment counter _______
    ; Start iterating through each character in the string.
    .next:
        inc edi                     ; Increment the string index.
        jmp .characterIteration     ; Iterate over the next character in the string.

    ;_______________________________ Update VGA cursor and Return ____________________________________
    ; Update the hardware cursor with VGA, Update the complete string all at once because VGA is slow.
    .finished:
        mov bh, byte[_cursorPositionY]; Set the high side of the the base register to the y position.
        mov bl, byte[_cursorPositionX]; Set the low side of the base register to the x position.
        call moveCursor32           ; Call the function that updates the hardware cursor through VGA.
        popa                        ; Restore the CPU register.
        ret                         ; And return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ moveCursor32
;   Description:
;   This updates the hardware cursor using the CRT microcontroller that is part of VGA. Because we are calculating
;   the relative position of the cursor we can ignore the the byte alignment. SO Position = X + Y * COLUMNS
;
;   Function Arguments:
;   bl      For setting the X position.
;   bh      For setting the y position.
bits 32

%define VGA_CRT_INDEX_REG   0x03D4
%define VGA_CRT_DATA_REG    0x03D5

moveCursor32:
    pusha                           ; Save the current register states.

    ; Get the current position.
    xor eax, eax                    ; Clear the eax register.
    mov ecx, COLUMNS                ; Get the number of columns there are in a single line.
    mov al, bh                      ; Get the Y position that was passed as argument.
    mul ecx                         ; Multiply Y by the amount of columns.
    add al, bl                      ; And finally add X to it.
    mov ebx, eax                    ; Save the value to the Base Register.

    ; Set the cursor low to the VGA CRT register (see CRT table above)
    mov al, 0x0F                    ; Get the CRT cursor location low address.
    mov dx, VGA_CRT_INDEX_REG       ; Get the VGA CRT index register address.
    out dx, al                      ; Write the cursor location low to the CRT index register.
    mov al, bl                      ; Get the X position that was passed as an argument.
    mov dx, VGA_CRT_DATA_REG        ; Get the VGA CRT data register address.
    out dx, al                      ; Write the X position to the to the VGA CRT data register.

    ; Set the cursor high to the VGA CRT register (see CRT table at the bottom of this file.)
     mov al, 0x0E                    ; Get the CRT cursor location high address.
     mov dx, VGA_CRT_INDEX_REG       ; Get the VGA CRT index register address.
     out dx, al                      ; Write the cursor location low to the CRT index register.
     mov al, bh                      ; Get the Y position that was passed as an argument.
     mov dx, VGA_CRT_DATA_REG        ; Get the VGA CRT data register address.
     out dx, al                      ; Write the Y position to the to the VGA CRT data register.

     ; Return
     popa                           ; Restore the register states.
     ret                            ; Return to the caller.


;_________________________________________________________________________________________________________________________/ ϝ clearDisplay32
;   Description:
;   This function will clear all text from the display using direct video memory access.
;
bits 32
clearDisplay32:
    pusha
    cld
    mov edi, VIDEO_MEMORY           ; Move the data index to the location of the video memory.
    mov cx, 2000                    ; Set the counter to 2000.
    mov ah, CHAR_ATTRIBUTE          ; Set the character attributes to the default value.
    mov al, ' '                     ; Set the character to print to an space character to overwrite everything with.
    rep stosw                       ; Print 2000 space characters to the screen, effectively clearing it.

    mov byte[_cursorPositionX], 0   ; Set the X position of the cursor to 0, to start at the first column.
    mov byte[_cursorPositionY], 0   ; Set the Y position of the cursor to 0, to start at the first line.
    popa                            ; Restore the CPU state.
    ret                             ; Return to the caller of the function.

;_________________________________________________________________________________________________________________________/ ϝ cursorLocation32
;   Description:
;   Move the cursor to an specific location on the screen.
;
;   Function Arguments:
;   al      For setting the X position.
;   ah      For setting the Y position.
bits 32
cursorLocation32:
    pusha                           ; Save the CPU registers.
    mov byte[_cursorPositionX], al  ; Set the X position of the cursor to 0, to start at the first column.
    mov byte[_cursorPositionY], ah  ; Set the Y position of the cursor to 0, to start at the first line.
    popa                            ; Restore the CPU registers.
    ret                             ; Return to the caller.

%endif ; __STDIO_ASM_INCLUDED__
;
;                               + ADDITIONAL INFORMATION REFERENCED IN THE CODE ABOVE.
;
;________________________________________________________________________________________________________________________/ ℹ CRT Microcontroller register
; This is an table of all memory offsets that are used by the CRT register controlling the hardware cursor.
;Index offset        Action                             ;Index offset       Action
;   0x0         Horizontal Total                        ;   0xD        Start Address Low
;   0x1         Horizontal Display Enable End           ;   0xE        Cursor Location High
;   0x2         Start Horizontal Blanking               ;   0xF        Cursor Location Low
;   0x3         End Horizontal Blanking                 ;   0x10       Vertical Retrace Start
;   0x4         Start Horizontal Retrace Pulse          ;   0x11       Vertical Retrace End
;   0x5         End Horizontal Retrace                  ;   0x12       Vertical Display Enable End
;   0x6         Vertical Total                          ;   0x13       Offset
;   0x7         Overflow                                ;   0x14       Underline Location
;   0x8         Preset Row Scan                         ;   0x15       Start Vertical Blanking
;   0x9         Maximum Scan Line                       ;   0x16       End Vertical Blanking
;   0xA         Cursor Start                            ;   0x17       CRT Mode Control
;   0xB         Cursor End                              ;   0x18       Line Compare
;   0xC         Start Address High
;________________________________________________________________________________________________________________________/ ℹ Character Attribute table.
; This is an table describing some character attributes for printing characters using VGA.
; Bits  Description
; 0-2   Foreground color of an character.
; 0     red
; 1     green
; 2     blue
; 3     The intensity of the foreground color.
; 4-6   Background color of an character.
; 4     red
; 5     green
; 6     blue
; 7     Background intensity or let the character blink depending on the VGA implementation.
;
; COLOR EXAMPLES:
; |   Background        Foreground     |
; | 64  32  16  8      4   2   1   0   |
; | 7   6   5   4      3   2   1   0   |
; | BG  BL  GR  RD     FG  BL  GR  RD  | HEX   DEC
; |---------------     ----------------|---------------------------
; | 0   0   0   0      1   1   1   1   | 0F    15  White on Black
; | 0   0   0   1      1   1   1   1   | 1F    31  White on Dark blue
; | 0   0   1   0      1   1   1   1   | 2F    47  White on Dark green
; | 0   0   1   1      1   1   1   1   | 3F    63  White on Cyan

; | 0   1   0   0      1   1   1   1   | 4F    79  White on Red
; | 0   1   0   1      1   1   1   1   | 5F    95  White on Magenta
; | 0   1   1   0      1   1   1   1   | 6F    111 White on Brown
; | 0   1   1   1      1   1   1   1   | 7F    127 White on Light Gray

; | 1   0   0   0      1   1   1   1   | 8F    143 White on Dark Gray
; | 1   0   0   1      1   1   1   1   | 9F    63  White on Light Blue
; | 1   0   1   0      1   1   1   1   | AF    63  White on Light Green
; | 1   0   1   1      1   1   1   1   | BF    63  White on Light Cyan

; | 1   1   0   0      1   1   1   1   | CF    63  White on Light Red
; | 1   1   0   1      1   1   1   1   | DF    63  White on Light Magenta
; | 1   1   1   0      1   1   1   1   | EF    63  White on Light Brown
; | 1   1   1   1      1   1   1   1   | FF    63  White on White
