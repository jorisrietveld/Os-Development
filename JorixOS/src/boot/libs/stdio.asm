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
bits 16

%include "libs/common.inc"

;_________________________________________________________________________________________________________________________/ § 32 bit IO
;   This section contains standard IO functions in 32 bits that are used when the CPU switched to Protected Mode.
; Character Attribute table.
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
bits 32
%define     VIDEO_MEMORY    0xB8000     ; The address maped to video memory in VGA mode 7.
%define     COLUMNS         80          ; The amount of columns on the screen.
%define     LINES           25          ; The amount of lines on the screen.
%define     CHAR_ATTRIBUTE  0x1F        ; The default character attribute (white char on black background)

_cursorPositionX db 0
_cursorPositionY db 0

;_________________________________________________________________________________________________________________________/ ϝ printCharacter32
;   This function prints a single character to the screen using direct video memory access.
;                                                                                   Input:      bl for an character.
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
    cmp bl, 0x0A                    ; Do we need to print an newline character?
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
;   This function prints a string to the screen using direct video memory access.
;                                                                                   Input:      bl for an character.
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

;___________________________________ CRT Microcontroller register _________________________________________
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


;_________________________________________________________________________________________________________________________/ ϝ moveCursor32
;   This updates the hardware cursor using the CRT microcontroller that is part of VGA. Because we are calculating
;   the relative position of the cursor we can ignore the the byte alignment. SO Position = X + Y * COLUMNS
;                                                                                       Input:      bl for position X
;                                                                                                   bh for position Y
bits 32
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
    mov dx, 0x03D4                  ; Get the VGA CRT index register address.
    out dx, al                      ; Write the cursor location low to the CRT index register.
    mov al, bl                      ; Get the X position that was passed as an argument.
    mov dx, 0x03D5                  ; Get the VGA CRT data register address.
    out dx, al                      ; Write the X position to the to the VGA CRT data register.

    ; Set the cursor high to the VGA CRT register (see CRT table above)
     mov al, 0x0E                    ; Get the CRT cursor location high address.
     mov dx, 0x03D4                  ; Get the VGA CRT index register address.
     out dx, al                      ; Write the cursor location low to the CRT index register.
     mov al, bh                      ; Get the Y position that was passed as an argument.
     mov dx, 0x03D5                  ; Get the VGA CRT data register address.
     out dx, al                      ; Write the Y position to the to the VGA CRT data register.

     ; Return
     popa                           ; Restore the register states.
     ret                            ; Return to the caller.


;_________________________________________________________________________________________________________________________/ ϝ clearDisplay32
;   This function will clear all text from the display using direct video memory access.
bits 32
clearDisplay32:
    pusha
    cld
    mov edi, VIDEO_MEMORY           ; Move the data index to the location of the video memory.
    mov cx, 2000                    ; Set the counter to 2000.
    mov ah, CHAR_ATTRIBUTE          ; Set the character attributes to the default value.
    mov al, ' '                     ; Set the character to print to an space character to overwrite everything with.
    rep stosw                       ; Print 2000 space characters to the screen, effectively clearing it.

    mov byte[_cursorPositionX], 0x00; Set the X position of the cursor to 0, to start at the first column.
    mov byte[_cursorPositionY], 0x00; Set the Y position of the cursor to 0, to start at the first line.
    popa                            ; Restore the CPU state.
    ret                             ; Return to the caller of the function.
;_________________________________________________________________________________________________________________________/ ϝ cursorLocation32
;   Move the cursor to an specific location on the screen.
;                                                                                       Input:      al for position X
;                                                                                                   ah for position Y
bits 32
cursorLocation32:
    pusha                           ; Save the CPU registers.
    mov byte[_cursorPositionX], al  ; Set the X position of the cursor to 0, to start at the first column.
    mov byte[_cursorPositionY], ah  ; Set the Y position of the cursor to 0, to start at the first line.
    popa                            ; Restore the CPU registers.
    ret                             ; Return to the caller.




