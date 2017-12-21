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
;                                                                                                        Enable A20    ;                                                                                                                     ;
;   Description:                                                                                         ̅̅̅̅̅̅̅̅̅̅    ;
;   This file includes routines to enable the A20 gate, this allows for signals to be received/send on the A20 line.   ;
;   This "Feature" was introduced because programmers found A bug in memory addressing, and decided to heavily rely    ;
;   on it. They would call to line A20 which would cause the address to "Wrap around" to address 0x0000:0x0000. IMB    ;
;   made the decision to solve this problem the correct way by fixing motherboard with some duct tape, zip ties and    ;
;   thee spoon of black magic (Placing a Logic OR gate on line 20 so you can enable/disable legacy bugs). Because of   ;
;   this we have to enable the A20 gate using the universally global standard method that differs on many systems.     ;
;   The method that is mostly used is by using your standard CPU logic configuration port "The keyboard controller"    ;
;   of course. If this method does not work on your machine use the alternate permanent fuse method by placing your    ;
;   device in an 1200 watt microwave and hope for the best. (I AM NOT RESPONSIBLE FOR ANY DAMAGED EQUIPMENT ETC...)    ;
;                                                                                                                      ;
;   Created: 21-12-2017 00:16                                                                                          ;
;                                                                                                                      ;
%ifndef A20_ENABLE_DISABLE_32
%define A20_ENABLE_DISABLE_32

;_________________________________________________________________________________________________________________________/ A20 Wait keyboard output
enable_A20:
    pusha   ; Store all current CPU registers to the stack so we can restore them after the execution of this function.
    cli     ; Disable hardware interrupts that could triple fault the CPU.

    ;_____________ A20 With Keyboard out __________________
    ; Enable A20 with the keyboard output port. (default)
    .with_keyboard_output:
        call A20_wait_input
        mov al, 0xAD
        out 0x64, al
        call A20_wait_input

        mov al, 0xD0
        out 0x64, al
        call A20_wait_output

        in al, 0x60
        push eax
        call A20_wait_input

        mov al, 0xD1
        out 0x64, al
        call A20_wait_input

        pop eax
        or al, 0x02
        out 0x60, al

        call A20_wait_input
        mov al, 0xAE
        out 0x64, al

        call A20_wait_input
        jmp .return

    ;___________ A20 With keyboard controller _______________
    ; Enable A20 with keyboard controller
    .with_keyboard_controller:
        mov al, 0xDD
        out 0x64, al
        jmp .return

    ;_____________ A20 With BIOS interrupt __________________
    ; Enable A20 with an BIOS interrupt call.
    .with_BIOS:
        mov ax, 0x2401
        int 0x15
        jmp .return

    ;_____________ A20 With system control __________________
    ; Enable A20 with the system control register.
    .with_system_control_a:
        mov al, 0x02
        out 0x92
        jmp .return

    ;___________________ loopFilename _______________________
    ; Restore the CPU register state and re-enable interrupts
    .return:
        sti
        popa
        ret
;_________________________________________________________________________________________________________________________/ A20 Wait Keyboard input
A20_wait_input:
    in al, 0x64         ; Read from keyboard status register
    test al, 0x02       ; Test if bit 2 is set in the status register. see [1] below for an detailed explanation.
    jnz A20_wait_input ; The keyboard is not ready so wait till the head death of the universe.
    ret
;_________________________________________________________________________________________________________________________/ A20 Wait keyboard output
A20_wait_output:
    in al, 0x64
    test al, 0x01
    jz A20_wait_output
    ret

;_____________________________________________________________________________________/ [1] Keyboard Controller Status register
; Bit   Description
; 0     Output buffer status ready, 0 the buffer is empty and 1 the buffer is filled.
; 1     Input buffer full, 0 ready to be written and 1 full do not write to it.
; 2     System flag, 0 is set after an power on reset and 1 after completing an successful BAT test.
; 3     command data, 0 last write to input buffer was data (port 0x60), 1 last was a command (port 64)
; 4     keyboard locked, 0 locked, 1 not locked and 2 means you broke math, great
; 5     Auxiliary output buffer full
; 6     Timeout, 0 ok flag and 1 means a time out.
; 7     Parity error, 0 ok flag (no errors), 1 PARTY!(parity) error with the last bytes.

%endif
