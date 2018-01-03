;_________________________________________________________________________________________________________________________/ Gdt.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 20-12-2017 07:25
;
;   Description:
;   This file defines the GDT (General Descriptor Table). The general descriptor table defines an common structure
;   for each programs memory. this is needed to separate different types of data while using the CPU in protected
;   mode. The table defines segments that are only allowed to contain data (variables) this section is called the
;   data section, an segment for storing executable code: text segment and later maybe an rodata (read only data),
;   init (runtime initialization), fini (runtime finalization), debug (used to leak sensitive data) and a comment
;   section (For version control).
;
%ifndef __GDT_ASM_INCLUDED__
%define __GDT_ASM_INCLUDED__

bits	16

;________________________________________________________________________________________________________________________/ ϝ BIOS Parameter Block
;   Description:
;   This function will install the general descriptor table to the special CPU register: GDTR (General Descriptor Table
;   Register). It does this using the dedicated lgdt (Load General Descriptor Table) instruction in ring 0.
;
InstallGDT:
	cli         ; Clear interrupts to prevent the cpu from tipple faulting on hardware and software interrupts.
	pusha       ; Save the current state of the CPU registers.
	lgdt [toc]  ; Load GDT into the GDTR using the dedicated lgdt instruction. (Only ring 0)
	sti         ; Re-enable the interrupts.
	popa        ; restore CPU registers
	ret         ; And return to the caller.

;________________________________________________________________________________________________________________________/ § GDT General Descriptor table
;   Description:
;   The segment descriptors that define what types of segments are available.
gdt_data:
	dd 0            ; null descriptor (Double word, 4 byte)
	dd 0            ; null descriptor (Double word, 4 byte)
    ;_______________________ GDT code descriptor ___________________________
    ; Describes an segment that can be used for executable instructions.
    ;11111111 11111111 00000000 00000000 00000000 10011010 11001111 00000000
	dw 0xFFFF       ; Segmentation limit low bits 0-15
	dw 0            ; Base address low bits 16-30
	db 0            ; base address middle bits 31-39
	db 0b10011010   ; access bits 40 - 47:
	    ;Bit  Bit(GDT)  Description
        ; 0     40      Access bit (Used with virtual memory), set to 0 because we don't use virtual memory.
        ; 1     41      Readable/Writeable bit, it is set to 1 to allow reading and executing instructions.
        ; 2     42      Expansion direction bit, set to 0
        ; 3     43      Code/Data descriptor, set to 1 because this is an code descriptor.
        ; 4     44      System Code/Data descriptor, set to 1 because it is an code descriptor for the kernel.
        ; 5-6   45-46   Ring level bit, set to 00 this descriptor allows for ring 0 code.
        ; 7     47      In memory bit (Used with virtual memory), set to 0 because we don't use virtual memory.
	db 0b11001111   ; granularity bits 48-55
	    ;Bit  Bit(GDT)  Description
        ; 0-3   48-51  The segmentation limit, set to 0xF this means we can access up to 0xffff byte of memory.
        ; 4     52     OS reserved, for now set it to 0.
        ; 5     53     reserved, can be for everything for now set it to 0.
        ; 6     54     Segmentation type (16/32), Set to 1 for an 32 bits system.
        ; 7     55     Granularity, set it to 1 to make every segment bound to 4 KB
	db 0            ; base high (starting address), set to 0 because programmers count from zero (⌐■_■).
	;
    ;___________________________ GDT code descriptor __________________________
    ; Describes an segment that can be used for storing variables and constants
    ; 11111111 11111111 00000000 00000000 00000000 10010010 11001111 00000000
	dw 0xFFFF       ; Segmentation limit low bits 0-15
	dw 0            ; Base address low bits 16-30
	db 0            ; base address middle bits 31-39
	db 0b10010010   ; access bits 40 - 47
	    ;Bit  Bit(GDT)  Description
        ; 0     40      Access bit (Used with virtual memory), set to 0 because we don't use virtual memory.
        ; 1     41      Readable/Writeable bit, it is set to 1 to allow reading and executing instructions.
        ; 2     42      Expansion direction bit, set to 0
        ; 3     43      Code/Data descriptor, set to 0 because this is an data descriptor.
        ; 4     44      System Code/Data descriptor, set to 1 because it is an code descriptor for the kernel.
        ; 5-6   45-46   Ring level bit, set to 00 this descriptor allows for ring 0 code.
        ; 7     47      In memory bit (Used with virtual memory), set to 0 because we don't use virtual memory.
	db 0b11001111   ; granularity bits 48-55
        ;Bit  Bit(GDT)  Description
        ; 0-3   48-51  The segmentation limit, set to 0xF this means we can access up to 0xffff byte of memory.
        ; 4     52     OS reserved, for now set it to 0.
        ; 5     53     reserved, can be for everything for now set it to 0.
        ; 6     54     Segmentation type (16/32), Set to 1 for an 32 bits system.
        ; 7     55     Granularity, set it to 1 to make every segment bound to 4 KB
	db 0            ; base high (starting address), set to 0 because programmers count from zero (⌐■_■).

end_of_gdt:

toc:    ;
	dw end_of_gdt - gdt_data - 1    ; limit, this is the size of the GDT (The ending address - the data -1)
	dd gdt_data                     ; base of GDT, just the starting address.


%endif ;__GDT_ASM_INCLUDED__
