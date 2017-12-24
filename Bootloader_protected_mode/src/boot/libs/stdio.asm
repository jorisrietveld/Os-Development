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
		ret	            ; we are done, so return
