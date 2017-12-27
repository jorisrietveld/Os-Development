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

;_________________________________________________________________________________________________________________________/ ϝ put_string_16
;   This function prints a string to the screen.
put_string_16:
	pusha				; save registers

    .print_char:
		lodsb           ; load next byte from string from SI to AL
		or	al, al      ; Does AL=0?
		jz	.return		; Yep, null terminator found-bail out
		mov	ah, 0x0E	; Nope-Print the character
		int	0x10	    ; invoke BIOS
		jmp	.print_char	    ; Repeat until null terminator found

    .return:
		popa            ; restore registers
		ret	            ; we are done, so return

;_________________________________________________________________________________________________________________________/ ϝ put_string_16
;   This function prints a string to the screen.
bits 32

%define     VIDEO_MEMORY    0xB8000     ; The address maped to video memory in VGA mode 7.
%define     COLUMNS         80          ; The amount of columns on the screen.
%define     LINES           25          ; The amount of lines on the screen.
%define     CHAR_ATTRIBUTE  14          ; The default character attribute (white char on black background)
    ; Bits
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
_cursorPositionX db 0
_cursorPositionY db 0

;_________________________________________________________________________________________________________________________/ ϝ putChar32
;   This function prints a string to the screen.
;   Input registers: bl for an character.
putChar32:
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
    pop eax                         ; Push the calculated value on to the stack.
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
    cmp [_cursorPositionY], COLUMNS ; Check if we are at the end of the line.
    je .row                         ; If so insert an new line feed.
    jmp .done                       ; Else jump to the exit routine.

    ; Move to an new line feed.
    .row:
    mov byte[_cursorPositionX], 0x00; Go back to column 0 on the new line.
    inc byte[_cursorPositionY]      ; Increment the line number.

    ; Finished printing, restore the CPU registers and return to the caller.
    .done:



