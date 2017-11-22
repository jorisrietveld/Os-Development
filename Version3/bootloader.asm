;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This bootloader will leave 16 bit real mode and switch to protected mode
;
bits    16                  ; Configure NASM for Real Mode.
org     0x7C00              ; Set program offset at 0x7C00.



_start:
	mov ax, 07C0h		; move 0x7c00 into ax
	mov ds, ax			; set data segment to where we're loaded

	mov si, string	; Put string position into SI
	call print_string	; Call our string-printing routine

	jmp $			; infinite loop!

	string db "Welcome to @OsandaMalith's First OS :)", 0

print_string:
	mov ah, 0Eh		; int 10h 'print char' function

.loop:
	lodsb			; load string byte to al
	cmp al, 0 		; cmp al with 0
	je .done		; if char is zero, ret
	int 10h			; else, print
	jmp .loop

.done:
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature