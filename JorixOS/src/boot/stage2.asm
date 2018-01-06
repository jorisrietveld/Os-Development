;_________________________________________________________________________________________________________________________/ Stage2.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 03-01-2018 00:28
;
;   Description:
;   This file contains the second stage of the bootloader. Because of the memory size constrains of only 512 bytes,
;   we have split the bootloader into two stages. One for setting up the minimal requirements of the system and a
;   second one that can switch the CPU into protected mode and knows how to locate and start the operating system.
;   This file contains the second stage that is responsible for loading the kernel. It contains both 16 bit and 32
;   bit assembler code because it will switch the CPU from 16 bit real mode to 32 bit protected mode.
;
bits 16                 ; Assemble to 16 bit instructions (For 16 bit real-mode)
org 0x500               ; Offset to address 0x50:0

jmp main                ; Jump to main.

%include "libs/stdio.asm"     ; This file contains IO functions for real and protected mode.
%include "libs/Gdt.asm"       ; This file contains the General Descriptor Table.
%include "libs/A20.asm"       ; This file contains functions for changing the A20 gate.
%include "libs/Fat12.asm"     ; This file contains an FAT12 driver.
%include "libs/Common.asm"    ; This file contains global data like variables, macros and constants.

;________________________________________________________________________________________________________________________/ § data section
msg_gdt     db "Installed GDT...", 0x0D, 0x0A, 0   ; Create an message.
msg_a20     db "Enabled the A20 line...", 0x0D, 0x0A, 0   ; Create an message.
msg_switch  db "Switching the CPU into protected mode...", 0x0D, 0x0A, 0   ; Create an message.
msg_fail    db "Error loading the kernel", 0x0D, 0x0A, 0
;________________________________________________________________________________________________________________________/ § text section
;   Description:
;   The second stage of the bootloader, this stage executes after the bootstrap loader is finished preparing the system.
;   This section will switch the CPU from real mode to protected mode. It defines the GDT to use and enables the A20 line.
;
main:
    ; Align the segments to the new locations.
    cli                         ; clear the interrupts to prevent the CPU from tipple faulting while moving the segments.
    xor ax, ax                  ; Clear the accumulator.
    mov ds, ax                  ; Move the data segment to location 0.
    mov es, ax                  ; Move the extra segment to location 0.
    mov ax, 0x0              ; Set the the location to place the stack segment.
    mov ss, ax                  ; Actually move the stack segment.
    mov sp, 0xFFFF              ; Set the base of the stack at 0xFFFF (grows down to 0x9000).
    sti                         ; Re-enable the interrupts.

    ; Define GDT
    call InstallGDT             ; Install the global descriptor table in the GDTR of the CPU.
    call enable_A20             ; Enable the A20 line by flipping the A20 gate.
    call loadRootDirectory      ; Load the root directory in to memory.

    mov	ebx, 0                  ; BX:BP points to buffer to load to
    mov	bp, IMAGE_REAL_MODE_BASE
    mov	si, ImageName           ; our file to load
    call loadFile               ; load our file
    mov	dword [ImageSize], ecx  ; save size of kernel
    cmp	ax, 0                   ; Test for success
    je	enterStage3             ; yep--onto Stage 3!
    mov	si, msg_fail          ; Nope--print error
    call printString16
    mov	ah, 0
    int 0x16                    ; await keypress
    int 0x19                    ; warm boot computer
    cli                         ; If we get here, something really went wong
    hlt
;_________________________________________________________________________________________________________________________/ § enter_stage3
;   This section will switch the CPU into protected mode and jump the the third stage of the bootloader.
enterStage3:
    cli                         ; Disable the interrupts because they will tipple fault the CPU in protected mode.
    mov eax, cr0                ; Get the value of the control register and copy it into eax.
    or eax, 1                   ; Alter the protected mode enable bit, set it to 1 so the CPU switches to it.
    mov cr0, eax                ; Copy the altered value with protected mode enabled back into the control register effectively switching modes.
    jmp CODE_DESC:stage3        ; Jump to label that configures the CPU for 32 bits protected mode.

;________________________________________________________________________________________________________________________/ § Stage 3
;   Description:
;   The third stage of the bootloader, this stage executes after the CPU has switch to 32 bits protected mode. It is
;   important to remember that it is not allowed to use BIOS interrupts, it will cause a tipple fault on the CPU that
;   will crash the computer.
;
bits 32 ; Configure the assembler to assemble into 32 bit machine instructions.

stage3:
    mov ax, DATA_DESC       ; Set the starting address of the segments.
    mov ds, ax              ; Move the data segment to the address 0x10.
    mov ss, ax              ; Move the stack segment to the address 0x10.
    mov es, ax              ; Move the extra segment to the address 0x10.
    mov esp, 0x9000         ; Move the top of the stack to location 0x9000.

copyImage:
    mov eax, dword[ImageSize]
    movzx ebx, word[sectorSize]
    mul ebx
    mov ebx, 4
    div ebx
    cld
    mov esi, IMAGE_REAL_MODE_BASE
    mov edi, IMAGE_PROTECTED_MODE_BASE
    mov ecx, eax
    rep movsd

    jmp CODE_DESC:IMAGE_PROTECTED_MODE_BASE ; Jump to the kernel.

    cli                     ; Clear all interrupts.
    hlt                     ; And halt the system.

;    call clearDisplay32
;printBootMenu:
;    ; Print the title of the menu page.
;    mov ebx, TITLE
;    call printString32
;
;    .printBootOptions:
;        ; Print the menu and its options.
;        mov ebx, MENU_HR
;        call printString32
;
;        mov ebx, MENU_OPT_1
;        call printString32
;
;        mov ebx, MENU_OPT_2
;        call printString32
;
;        mov ebx, MENU_OPT_3
;        call printString32
;
;        mov ebx, MENU_OPT_4
;        call printString32
;
;        mov ebx, MENU_FOOTER
;        call printString32
;
;        mov ebx, MENU_SELECT_0
;        call printString32
;
;stop: ; Halt and catch fire...
;    cli
;    hlt
;
;TITLE           times 2 db  0x0A
;                db "________________________________[ Jorix OS ]____________________________________",0x0A
;                times 80 db "="
;                db          0x0A, 0
;MENU_HR         db "                NUM    OPTIONS", 0x0A, 0
;MENU_OPT_1      db "                [1]    Start JoriX OS in normal mode.", 0x0A, 0
;MENU_OPT_2      db "                (2)    Start JoriX OS in recovery mode.", 0x0A, 0
;MENU_OPT_3      db "                (3)    Start JoriX OS in debuggin mode.", 0x0A, 0
;MENU_OPT_4      db "                (4)    Start Teteris.", 0x0A, 0
;MENU_OPT_5      db "                (5)    Shutdown the pc.", 0x0A, 0
;MENU_FOOTER     times 80 db "="
;                db 0x0A, 0
;MENU_SELECT_0   db "               Please use your arrow keys to select an option.   ", 0x0A, 0
;MENU_SELECT_1   db "               Press enter to start Jorix OS in normal mode   ", 0x0A, 0
;MENU_SELECT_2   db "               Press enter to start Jorix OS in recovery modes.", 0x0A, 0
;MENU_SELECT_3   db "               Press enter to start Jorix OS with debugging tools.", 0x0A, 0
;MENU_SELECT_4   db "               Press enter to play teteris.", 0x0A, 0
;MENU_SELECT_5   db "               Press enter to shutdown your pc.", 0x0A, 0


