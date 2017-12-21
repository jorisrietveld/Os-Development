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
enable_A20:
    pusha

    .read_output:
        mov al, 0xD0        ; Set read output port command to low bit of ax.
        out 0x64, al        ; Write command to keyboard output port.
        call .wait_input    ; Wait for an response from the keyboard controller.

        in al, 0x60         ; Read from the keyboard controller.
        push eax            ; Save the value on the stack.
        call .wait_input    ;

        mov al, 0xD1
        out 0x64, al
        call .wait_input

    .wait_input:
        in al, 0x64     ; Read from keyboard status register
        test al, 0x02   ; Test if bit 2 is set in the status register.
            ; Bit   Description
            ; 0     Output buffer status ready, 0 the buffer is empty and 1 the buffer is filled.
            ; 1     Input buffer full, 0 ready to be written and 1 full do not write to it.
            ; 2     System flag, 0 is set after an power on reset and 1 after completing an successful BAT test.
            ; 3     command data, 0 last write to input buffer was data (port 0x60), 1 last was a command (port 64)
            ; 4     keyboard locked, 0 locked, 1 not locked and 2 means you broke math, great
            ; 5     Auxiliary output buffer full
            ; 6     Timeout, 0 ok flag and 1 means a time out.
            ; 7     Parity error, 0 ok flag (no errors), 1 PARTY!(parity) error with the last bytes.
        jnz .wait_input


mov al, 0xD0
out 0x064
call wait_output
