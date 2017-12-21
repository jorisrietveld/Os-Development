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
;                                                                                           Second Stage Bootloader    ;                                                                                                                     ;
;   Description:                                                                            ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅    ;
;   This file contains the second stage of the bootloader. Because of the memory size constrains of only 512 bytes,    ;
;   we have split the bootloader into two stages. One for setting up the minimal requirements of the system and a      ;
;   second one that can switch the CPU into protected mode and knows how to locate and start the operating system.     ;
;   This file contains the second stage that is responsible for loading the kernel. It contains both 16 bit and 32     ;
;   bit assembler code because it will switch the CPU from 16 bit real mode to 32 bit protected mode.                  ;
;                                                                                                                      ;
;   Created: 13-11-2017 21:40       Altered: 20-12-2017 00:29                                                          ;
;                                                                                                                      ;

org 0x500    ; Offset to address 0
bits 16     ; Assemble to 16 bit instructions (For 16 bit real-mode)
jmp main    ; Jump to the main label.

%include "./features/stdio16.asm"
%include "./features/gdt.asm"

;________________________________________________________________________________________________________________________/ § BIOS Parameter Block
;   Description:
;   The third stage of the bootloader, this stage executes after the CPU has switch to 32 bits protected mode. It is
;   important to remember that it is not allowed to use BIOS interrupts, it will cause a tipple fault on the CPU that
;   will crash the computer.
;
main:
    cli             ; clear the interrupts to prevent the CPU from tipple faulting while moving the segments.
    xor ax, ax      ; Clear the accumulator.
    mov ds, ax      ; Move the data segment to location 0.
    mov es, ax      ; Move the extra segment to location 0.
    mov ax, 0x9000  ; Set the the location to place the stack segment.
    mov ss, ax      ; Actually move the stack segment.
    mov sp, 0xFFFF  ; Set the base of the stack at 0xFFFF (grows down to 0x9000).
    sti             ; Re-enable the interrupts.
    defstr msg_switch, "Switching the CPU into protected mode..."
    println msg_switch
    cli
    hlt
    call InstallGDT ; Install the global descriptor table in the GDTR of the CPU.
    cli             ; Disable the interrupts because they will tipple fault the CPU in protected mode.
    mov eax, cr0    ; Get the value of the control register and copy it into eax.
    or eax, 1       ; Alter the protected mode enable bit, set it to 1 so the CPU switches to it.
    mov cr0, eax    ; Copy the altered value with protected mode enabled back into the control register effectively switching modes.
    jmp 0x08:proteded_start     ; Jump to label that configures the CPU for 32 bits protected mode.

; String constants

;________________________________________________________________________________________________________________________/ § BIOS Parameter Block
;   Description:
;   The third stage of the bootloader, this stage executes after the CPU has switch to 32 bits protected mode. It is
;   important to remember that it is not allowed to use BIOS interrupts, it will cause a tipple fault on the CPU that
;   will crash the computer.
;
bits 32 ; Configure the assembler to assemble into 32 bit machine instructions.

proteded_start:
    mov ax, 0x10    ; Set the starting address of the segments.
    mov ds, ax      ; Move the data segment to the address 0x10.
    mov ss, ax      ; Move the stack segment to the address 0x10.
    mov es, ax      ; Move the extra segment to the address 0x10.
    mov esp, 0x9000 ; Move the top of the stack to location 0x9000.

stop: ; Halt and catch fire...
    cli
    hlt

