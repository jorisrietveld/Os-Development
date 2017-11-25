bits 32 ; Output 32 bits instructions for CPU protected mode.

boot2:
	mov ax, DATA_SEG    ; Copy second bootloader address to accumulator register.
	mov ds, ax          ;
	mov es, ax          ;
	mov fs, ax          ;
	mov gs, ax          ;
	mov ss, ax          ;
	mov esi,HELLO       ; Move hello string to segment register.
	mov ebx,0xb8000     ; Copy the segment register data to the VGA text buffer.
						; 0xb80FF
    call print_string

halt:
	cli
	hlt

HELLO db "Hello world!", 0 ; Define an string constant

%include "print_string.asm"