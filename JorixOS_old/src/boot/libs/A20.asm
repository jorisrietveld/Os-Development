;_________________________________________________________________________________________________________________________/ Stage2.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 21-12-2017 00:16
;
;   Description:
;   This file includes routines to enable the A20 gate, this allows for signals to be received/send on the A20 line.
;   This "Feature" was introduced because programmers found A bug in memory addressing, and decided to heavily rely
;   on it. They would call to line A20 which would cause the address to "Wrap around" to address 0x0000:0x0000. IMB
;   made the decision to solve this problem the correct way by fixing motherboard with some duct tape, zip ties and
;   thee spoon of black magic (Placing a Logic OR gate on line 20 so you can enable/disable legacy bugs). Because of
;   this we have to enable the A20 gate using the universally global standard method that differs on many systems.
;   The method that is mostly used is by using your standard CPU logic configuration port "The keyboard controller"
;   of course. If this method does not work on your machine use the alternate permanent fuse method by placing your
;   device in an 1200 watt microwave and hope for the best. (I AM NOT RESPONSIBLE FOR ANY DAMAGED EQUIPMENT ETC...)
;
%ifndef __A20_ASM_INCLUDED__
%define __A20_ASM_INCLUDED__

;_________________________________________________________________________________________________________________________/ ϝ disable_A20
;   Description:
;   This function will enable the A20 line by flipping the A20 Gate using different methods. If it doesnt work on your
;   machine just un comment the jmp after the cli and set it to an different method.
;
enable_A20:
    pusha   ; Store all current CPU registers to the stack so we can restore them after the execution of this function.
    cli     ; Disable hardware interrupts that could triple fault the CPU.
    ; jmp with_BIOS

    ;_____________ A20 With Keyboard out __________________
    ; Enable A20 with the keyboard output port. (default)
    .with_keyboard_output:
        call A20_wait_input ; Wait until the input port of the keyboard controller is empty.
        mov al, 0xAD        ; Set keyboard controller command to low bit of ax that will disable the keyboard.
        out 0x64, al        ; Write the disable keyboard command to the controller.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        mov al, 0xD0        ; Set the read output port command of the keyboard controller.
        out 0x64, al        ; Read from the output port.
        call A20_wait_output; Wait until the keyboard controller has written data to the output port.

        in al, 0x60         ; Get the output of the data port.
        push eax            ; And save it on the stack.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        mov al, 0xD1        ; Set the keyboard write output command.
        out 0x64, al        ; Write it to the keyboard controller.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        pop eax             ; Restore the previously saved response from the stack.
        or al, 0x02         ; Flip the second bit with an OR. This is the enable A20 command.
        out 0x60, al        ; Write the altered config back to the keyboard controller. This enables A20

        call A20_wait_input ; Wait until the controller signals that is received the command.
        mov al, 0xAE        ; Set the enable keyboard command.
        out 0x64, al        ; Write the enable keyboard command to the keyboard controller.

        call A20_wait_input ; Wait until the keyboard controller signals that the data is received.
        jmp .return         ; A20 is enabled so its time to move on.

    ;___________ A20 With keyboard controller _______________
    ; Enable A20 with keyboard controller
    .with_keyboard_controller:
        mov al, 0xDD        ; Use the standard 0xDD (Enable A20 Address Line) command.
        out 0x64, al        ; Write the command to the keyboard controller.
        jmp .return         ; A20 is enabled so its time to move on.

    ;_____________ A20 With BIOS interrupt __________________
    ; Enable A20 with an BIOS interrupt call.
    .with_BIOS:
        mov ax, 0x2401      ; Set the enable A20 BIOS command.
        int 0x15            ; Execute the BIOS interrupt that enables A20.
        jmp .return         ; A20 is enabled so its time to move on.

    ;_____________ A20 With system control __________________
    ; Enable A20 with the system control register.
    .with_system_control_a:
        mov al, 0x02        ; Set the enable A20 command.
        out 0x92, al        ; Write the command to the system control register.
        jmp .return         ; A20 is enabled so its time to move on.

     ;_____________ Return __________________
    .return:
        sti                 ; Re-enable interrupts.
        popa                ; Restore the CPU register states.
        ret                 ; Return to the caller.
;_________________________________________________________________________________________________________________________/ ϝ disable_A20
;   Description:
;   This function will disable the A20 line by flipping the A20 Gate using different methods. If it doesnt work on your
;   machine just un comment the jmp after the cli and set it to an different method.
;
disable_A20:
    pusha                   ; Save the current CPU register state.
    cli                     ; Disable all hardware interrupts.
    ; jmp with_BIOS

    ;_____________ A20 With Keyboard out __________________
    ; Enable A20 with the keyboard output port. (default)
    .with_keyboard_output:
        call A20_wait_input ; Wait until the input port of the keyboard controller is empty.
        mov al, 0xAD        ; Set keyboard controller command to low bit of ax that will disable the keyboard.
        out 0x64, al        ; Write the disable keyboard command to the controller.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        mov al, 0xD0        ; Set the read output port command of the keyboard controller.
        out 0x64, al        ; Read from the output port.
        call A20_wait_output; Wait until the keyboard controller has written data to the output port.
w
        in al, 0x60         ; Get the output of the data port.
        push eax            ; And save it on the stack.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        mov al, 0xD1        ; Set the keyboard write output command.
        out 0x64, al        ; Write it to the keyboard controller.
        call A20_wait_input ; Wait until the keyboard controller signals that the data is ready.

        pop eax             ; Restore the previously saved response from the stack.
        xor al, 0x02        ; Flip the second bit with an OR. This is the disable A20 command.
        out 0x60, al        ; Write the altered config back to the keyboard controller. This enables A20

        call A20_wait_input ; Wait until the controller signals that is received the command.
        mov al, 0xAE        ; Set the enable keyboard command.
        out 0x64, al        ; Write the enable keyboard command to the keyboard controller.

        call A20_wait_input ; Wait until the keyboard controller signals that the data is received.
        jmp .return         ; A20 is disabled so its time to move on.

    ;___________ A20 With keyboard controller _______________
    ; Enable A20 with keyboard controller
    .with_keyboard_controller:
        mov al, 0xDF        ; Set the disable A20 command.
        out 0x64, al        ; Execute the disable A20 command by sending it to the keyboard controller.
        jmp .return         ; A20 is disabled so its time to move on.

    ;_____________ A20 With BIOS interrupt __________________
    ; Enable A20 with an BIOS interrupt call.
    .with_BIOS:
        mov ax, 0x2400      ; Set the disable A20 BIOS command to ax.
        int 0x15            ; Execute the BIOS interrupt that disables the A20 line.
        jmp .return         ; A20 is disabled so its time to move on.

    ;_____________ A20 With system control __________________
    ; Enable A20 with the system control register.
    .with_system_control_a:
        in ax, 0x92         ; Read the system control register.
        test ax, 0x02       ; Test if the A20 line is enabled.
        jz .return          ; The A20 bit is already disabled.
        xor ax, 0x02        ; Toggle the 2 bit the enable A20 command.
        out 0x92, ax        ; Write the command to the system control register.
        jmp .return         ; A20 is enabled so its time to move on.

    ;_____________ Return __________________
    .return:
        popa                ; Restore previously saved CPU register states.
        sti                 ; Re-enable the hardware interrupts.
        sti                 ; Done disabling the A20 line return to the caller.

;_________________________________________________________________________________________________________________________/  ϝ A20_wait_input
; This function reads the keyboard controller status register and tests if the input buffer is ready, if not it waits.
A20_wait_input:
    in al, 0x64         ; Read from keyboard status register
    test al, 0x02       ; Test if bit 2 is set in the status register. see [1] below for an detailed explanation.
    jnz A20_wait_input  ; The keyboard is not ready so wait till the head death of the universe.
    ret                 ; Input ready return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ A20_wait_output
; This function reads the keyboard controller status register and tests if the output buffer is ready, if not it waits.
A20_wait_output:
    in al, 0x64         ; Read from the keyboard status register.
    test al, 0x01       ; Test if bit 1 is set in the status register. [1] below for an detailed explanation.
    jz A20_wait_output  ; If the output is not ready wait a bit longer.
    ret                 ; Output received return to the caller.

%endif ; __A20_ASM_INCLUDED__

;
;                               + ADDITIONAL INFORMATION REFERENCED IN THE CODE ABOVE.
;
;________________________________________________________________________________________________________________________/ ℹ Keyboard Controller Status register
; This table shows the bits in the keyboard status register.
; Bit   Description
; 0     Output buffer status ready, 0 the buffer is empty and 1 the buffer is filled.
; 1     Input buffer full, 0 ready to be written and 1 full do not write to it.
; 2     System flag, 0 is set after an power on reset and 1 after completing an successful BAT test.
; 3     command data, 0 last write to input buffer was data (port 0x60), 1 last was a command (port 64)
; 4     keyboard locked, 0 locked, 1 not locked and 2 means you broke math, great
; 5     Auxiliary output buffer full
; 6     Timeout, 0 ok flag and 1 means a time out.
; 7     Parity error, 0 ok flag (no errors), 1 PARTY!(parity) error with the last bytes.
