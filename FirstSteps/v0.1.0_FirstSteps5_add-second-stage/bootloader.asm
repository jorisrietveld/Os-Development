;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;
;

bits    16          ; Output 16 bits instructions for CPU real mode.
org     0x7C00      ; Start output after interrupt vectors.

boot:
	mov ax, 0x2401  ;
	int 0x15
	mov ax, 0x3
	int 0x10
	cli
	lgdt [gdt_pointer]
	mov eax, cr0
	or eax,0x1
	mov cr0, eax
	jmp CODE_SEG:boot2 ; Jump to the second part of the bootloader.

gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

%include "stage_two_bootloader.asm"

times 510 - ($-$$) db 0     ; Fill remaining 510 bytes of MBR with zeros to prevent unexpeced behaveour.
dw 0xAA55 ; Mark this sector (the 512 bytes used in the bootleader) as bootable with the magic constand.