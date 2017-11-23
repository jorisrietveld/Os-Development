
bits 32 ; Output 32 bits instructions for CPU protected mode.

boot2:
	mov ax, DATA_SEG    ; Copy second bootloader address to accumulator register.
	mov ds, ax          ;
	mov es, ax          ;
	mov fs, ax          ;
	mov gs, ax          ;
	mov ss, ax          ;
	mov esi,hello       ; Move hello string to segment register.
	mov ebx,0xb8000     ; Copy the segment register data to the VGA text buffer.

.loop:
	lodsb               ; Load the first byte from the segment register
	or al,al            ; Compare the al with al
	jz halt             ; If al contains an zero (string termination character) halt execution.
	or eax,0x0100       ;
	mov word [ebx], ax  ;
	add ebx,2           ; Increase the counter by 2
	jmp .loop           ; Go to the next character to print.

halt:
	cli
	hlt

HELLO: db "Hello world!",0  ; Define an string constant