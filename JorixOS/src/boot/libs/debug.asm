; 
; Author: Joris Rietveld - <jorisrietveld@gmail.com>  
; Github: <https://github.com/jorisrietveld>
; Date created: 07-09-2018 13:31
; Licence: GPLv3 - General Public Licence version 3 <https://www.gnu.org/licenses/gpl-3.0.txt>
; 
; Description: $DESCRIPTION$
;

%ifndef __DEBUG_ASM_INCLUDED__
%define __DEBUG_ASM_INCLUDED__

%define DEBUG_FAT12_DRIVER    ; This will generate info abount what files are scanned, size etc.


%macro print_reg 1
    mov dx, %1
    mov cx, 16
    print_reg_loop:
    	push cx
    	mov al, '0'
    	test dh, 10000000b
    	jz print_reg_do
    	mov al, '1'
    print_reg_do:
    	mov ah, 0x09               ; write character stored in AL
    	mov cx, 1
    	int 0x10
    	mov ah, 3                  ; move cursor one column forward
    	int 0x10
    	inc dx
    	mov ah, 2                  ; set cursor
    	int 0x10
    	pop cx
    	shl dx, 1
    	loop print_reg_loop
	    jmp $
%endmacro