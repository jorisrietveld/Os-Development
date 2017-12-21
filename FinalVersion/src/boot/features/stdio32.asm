;__________________________________________________________________________________________/ stdio32.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 20-12-2017 17:58
;   
;   Description:
;

%ifndef STD_IO_32_BIT
%define STD_IO_32_BIT

CLR_DEFAULT equ 0x0F
VIDEO_MEMORY equ 0xb8000

;________________________________________________________________________________________________________________________/ print_str
;   This function uses the video memory directly to print characters to the screen.
%macro print_str 1
    pusha   ; Save the current CPU registers state.
    mov edx, VIDEO_MEMORY

    .print_char:
        mov al, [ebx]
        mov ah, CLR_DEFAULT ; Set the high byte of the accumulator to white on black.
        cmp al, 0           ; Check for the null termination byte.
        je .done            ; If so jump to the location of the done routine.
        mov [edx], ax
        add ebx, 1
        add edx, 2
        jmp .print_char

    .done
%endif
