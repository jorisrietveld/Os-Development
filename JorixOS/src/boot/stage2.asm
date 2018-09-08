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
;   Created: 13-11-2017 21:40                                                                                          ;
;                                                                                                                      ;
bits 16     ; Assemble to 16 bit instructions (For 16 bit real-mode)
org 0x500    ; Offset to address 0
jmp main    ; Jump to the main label.

%include "libs/stdio.asm"             ; TODO MIGRATE TO intel16 lib.
%include "libs/gdt.inc"               ; TODO MIGRATE TO intel16 lib.
%include "libs/a20.inc"
%include "libs/common.inc"
%include "libs/utils.inc"
%include "libs/global.asm"
%include "libs/Fat12.asm"

;________________________________________________________________________________________________________________________/ § User feedback
string msg_press_any, "Press any key..."
string msg_disabled, "disabled"
string msg_enabled, "enabled"

string msg_gdt, "Installed GDT..."

string msg_a20_info, "Attempt to enable the a20 gate"
string msg_a20_status, "The A20 line is: "
string msg_a20_fatal, "Unable to switch the A20 gate."

string msg_load_root, "Loading the root directory..."
string msg_kernel_load_fatal, "Unable to load the kernel file."

string msg_switch, "Switching the CPU into protected mode..."
string msg_boot, "Start the kernel?"
;_______________________________________________________________________________________________________________________/ § text section
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
    println_16 msg_gdt

    ActivateA20Gate:
        println_16 msg_a20_info
        jmp .check

        .with_system_controll_port:
            call enable_a20_fast                ; Running out of options, try it the dangerous way that can blank the monitor.
            call .check                       ; Check if writing to the System Control Port worked...

        .with_bios:
            call enable_a20_bios                ; Enable the A20 line by flipping the A20 gate.
            jmp .check                          ; Check if writing to the System Control Port worked...

        .with_keyboard_controller:
            call enable_a20_keyboard            ; No luck, try writing to the keyboard (PC/2) controller.
            call .check                       ; Check if writing to the keyboard controller worked.

        .check:
            print_16 msg_a20_status
            call check_a20
            cmp ax, 1
            je .success
            print_16 msg_disabled
            ret

        .success:
            print_16 msg_enabled
            call WaitForKeyPress

    println_16 msg_load_root
    call LoadRootDirectory      ; Load the root directory in to memory.
 call WaitForKeyPress
    mov	ebx, 0                  ; BX:BP points to buffer to load to
    mov	bp, IMAGE_REAL_MODE_BASE
    mov	si, ImageName           ; our file to load
    call loadFile               ; load our file
    mov	dword [ImageSize], ecx  ; save size of kernel
    cmp	ax, 0                   ; Test for success
    je	enterStage3             ; yep--onto Stage 3!
    mov	si, msg_kernel_load_fatal          ; Nope--print error
    call decl_print_16
    mov	ah, 0
    int 0x16                    ; await keypress
    int 0x19                    ; warm boot computer
    cli                         ; If we get here, something really went wong
    hlt
;_________________________________________________________________________________________________________________________/ § enter_stage3
;   This section will switch the CPU into protected mode and jump the the third stage of the bootloader.
enterStage3:
call WaitForKeyPress
    println_16 msg_switch
    println_16 msg_boot
    call WaitForKeyPress
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
    mov esp, 90000h         ; Move the top of the stack to location 0x9000.

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

;;________________________________________________________________________________________________________________________/ ϝ Fatal Error Handler
;;   Description:
;;   This function gets executed when the bootloader encountered a problem that is could not recover from. It loops
;;   endlessly until the user presses a key that will reset the system.
;;
;RebootBecauseOfFailure:
;    call WaitForKeyPress
;     xor ah, ah                          ; Set 0 to the ax high byte as function.
;        int BIOS_INTERRUPT_KEYBOARD         ; Execute an BIOS interrupt that:
;        int BIOS_INTERRUPT_W_REBOOT         ; Reset the system.
;
;   ;int BIOS_INTERRUPT_REBOOT             ; It failed 5 times... reboot the system.
;   ;cli
;   ;hlt ; Shouldn't get called.
;
;;________________________________________________________________________________________________________________________/ § Stage 2 main code
;;   Description:
;;   The second stage of the bootloader, this stage executes after the bootstrap loader is finished preparing the system.
;;   This section will switch the CPU from real mode to protected mode. It defines the GDT to use and enables the A20 line.
;;
;main:
;    ; Align the segments to the new locations.
;    cli                         ; clear the interrupts to prevent the CPU from tipple faulting while moving the segments.
;    xor ax, ax                  ; Clear the accumulator.
;    mov ds, ax                  ; Move the data segment to location 0.
;    mov es, ax                  ; Move the extra segment to location 0.
;    mov ax, 0x0
;    mov ss, ax                  ; Actually move the stack segment.
;    mov sp, 0xFFFF              ; Set the base of the stack at 0xFFFF (grows down to 0x9000).
;    sti                         ; Re-enable the interrupts.
;
;    ; Define GDT
;    call InstallGDT             ; Install the global descriptor table in the GDTR of the CPU.
;    println_16 msg_gdt
;
;    ; Attempt to enable the A20 gate so the A20 address line can be used for larger addressing.
;    ;call CheckA20                       ; Check if the A20 gate is already enabled by the BIOS.
;    call enable_a20_bios                ; Try to enable the A20 gate with an BIOS interrupt.
;    jmp LoadKernelImages
;    ;call CheckA20                       ; Check if the BIOS interrupt worked.
;    ;call enable_a20_keyboard            ; No luck, try writing to the keyboard (PC/2) controller.
;    ;call CheckA20                       ; Check if writing to the keyboard controller worked.
;    ;call enable_a20_fast                ; Running out of options, try it the dangerous way that can blank the monitor.
;    ;call CheckA20                       ; Check if writing to the System Control Port worked...
;
;    ; In your case, switching the A20 gate might involve black magic.
;    println_16 msg_a20_fatal        ; Notify the user that the system is unable to switch the A20.
;    call RebootBecauseOfFailure     ;
;
;;________________________________________________________________________________________________________________________/ ϝ CheckA20
;;   Description:
;;   This function will check if the A20 gate is enabled. If so it moves on otherwise returnees to the caller.
;;
;    CheckA20:
;        print_16 msg_a20_status
;        call check_a20                      ; Check if the A20 line is enabled.
;        cmp ax, 1                           ; does check_a20 return a one?
;        je .a20_is_enabled
;        println_16 msg_disabled
;        ret                                 ; That did'nt work return to the caller.
;
;        .a20_is_enabled:
;            println_16 msg_enabled
;            ;jmp short LoadKernelImages
;    ;call LoadRootDirectory
;;	mov	ebx, 0			; BX:BP points to buffer to load to
;;    	mov	bp, IMAGE_REAL_MODE_BASE
;;	mov	si, ImageName		; our file to load
;;	call	loadFile		; load our file
;;	mov	dword [ImageSize], ecx	; save size of kernel
;;	cmp	ax, 0			; Test for success
;;	je	EnterStage3		; yej
;;		println_16 msg_kernel_load_fatal
;;	mov	ah, 0
;;	int     0x16                    ; await keypress
;;	int     0x19                    ; warm boot computer
;;	cli				; If we get here, something really went wong
;;	hlt
;
;
;;   LoadKernelImages:
;;       println_16 msg_load_root
;;       ;call loadRootDirectory
;;       call LoadRootDirectory
;;       ; TODO implement a way to search for kernel images.
;;       ;xor ebx, ebx
;;       println_16 msg_load_root
;;       ;call loadFAT
;;       mov ebx, 0
;;       mov bp, IMAGE_REAL_MODE_BASE
;;       mov si, ImageName               ; Set the name of the kernel file.
;;       call loadFile                       ; Load the kernel into ram.
;;       mov dword [ImageSize], ecx          ; Persist the size of the kernel.
;;       cmp ax, 0                           ; Check for errors.
;;       je EnterStage3                      ;
;;       println_16 msg_kernel_load_fatal    ; Notify the user that the system is unable to switch the A20.
;;       call RebootBecauseOfFailure         ;
;;       cli
;;       hlt
;;________________________________________________________________________________________________________________________/ § enter_stage3
;;   This section will switch the CPU into protected mode and jump the the third stage of the bootloader.
;;nterStage3:
;;   println_16 msg_switch
;;   call WaitForKeyPress
;;   cli                         ; Disable the interrupts because they will tipple fault the CPU in protected mode.
;;   mov eax, cr0                ; Get the value of the control register and copy it into eax.
;;   or eax, 1                   ; Alter the protected mode enable bit, set it to 1 so the CPU switches to it.
;;   mov cr0, eax                ; Copy the altered value with protected mode enabled back into the control register effectively switching modes.
;;   jmp 0x08:stage3     ; Jump to label that configures the CPU for 32 bits protected mode.
;
;;________________________________________________________________________________________________________________________/ § Stage 3
;;   Description:
;;   The third stage of the bootloader, this stage executes after the CPU has switch to 32 bits protected mode. It is
;;   important to remember that it is not allowed to use BIOS interrupts, it will cause a tipple fault on the CPU that
;;   will crash the computer.
;;
;;its 32 ; Configure the assembler to assemble into 32 bit machine instructions.
;
;;tage3:
;;   mov ax, 0x10    ; Set the starting address of the segments.
;;   mov ds, ax      ; Move the data segment to the address 0x10.
;;   mov ss, ax      ; Move the stack segment to the address 0x10.
;;   mov es, ax      ; Move the extra segment to the address 0x10.
;;   mov esp, 0x9000 ; Move the top of the stack to location 0x9000.
;
;;   call clearDisplay32
;
;;   MoveKernelImage:
;;       mov eax, dword [ImageSize]
;;       movzx ebx, word[sectorSize]
;;       mul ebx
;;       mov ebx, 4
;;       div ebx
;;       cld
;;       mov esi, IMAGE_REAL_MODE_BASE
;;       mov edi, IMAGE_PROTECTED_MODE_BASE
;;       mov ecx, eax
;;       rep movsd
;;printBootMenu:
;;    ; Print the title of the menu page.
;;    mov ebx, TITLE
;;    call printString32
;;
;;    .printBootOptions:
;;        ; Print the menu and its options.
;;        mov ebx, MENU_HR
;;        call printString32
;;
;;        mov ebx, MENU_OPT_1
;;        call printString32
;;
;;        mov ebx, MENU_OPT_2
;;        call printString32
;;
;;        mov ebx, MENU_OPT_3
;;        call printString32
;;
;;        mov ebx, MENU_OPT_4
;;        call printString32
;;
;;        mov ebx, MENU_FOOTER
;;        call printString32
;;
;;        mov ebx, MENU_SELECT_0
;;        call printString32
;;
;;stop: ; Halt and catch fire...
;;    cli
;;    hlt
;;
;;TITLE           times 2 db  0x0A
;;                db "________________________________[ Jorix OS ]____________________________________",0x0A
;;                times 80 db "="
;;                db          0x0A, 0
;;MENU_HR         db "                NUM    OPTIONS", 0x0A, 0
;;MENU_OPT_1      db "                [1]    Start JoriX OS in normal mode.", 0x0A, 0
;;MENU_OPT_2      db "                (2)    Start JoriX OS in recovery mode.", 0x0A, 0
;;MENU_OPT_3      db "                (3)    Start JoriX OS in debuggin mode.", 0x0A, 0
;;MENU_OPT_4      db "                (4)    Start Teteris.", 0x0A, 0
;;MENU_OPT_5      db "                (5)    Shutdown the pc.", 0x0A, 0
;;MENU_FOOTER     times 80 db "="
;;                db 0x0A, 0
;;MENU_SELECT_0   db "               Please use your arrow keys to select an option.   ", 0x0A, 0
;;MENU_SELECT_1   db "               Press enter to start Jorix OS in normal mode   ", 0x0A, 0
;;MENU_SELECT_2   db "               Press enter to start Jorix OS in recovery modes.", 0x0A, 0
;;MENU_SELECT_3   db "               Press enter to start Jorix OS with debugging tools.", 0x0A, 0
;;MENU_SELECT_4   db "               Press enter to play teteris.", 0x0A, 0
;;MENU_SELECT_5   db "               Press enter to shutdown your pc.", 0x0A, 0
;
;
;