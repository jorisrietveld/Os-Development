;__________________________________________________________________________________________/ a20.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 07-06-2018 14:19
;   
;   Description:
;   This file contains functions to handle everything concerning the A20 gate, like detecting the current sate of the
;   gate and several ways of switching it. Because switching the A20 gate is kind of a mess it is best if you first
;   check the current state, if its disabled then try to switch it with the bios interrupt. Then check it again to
;   verify that it worked, if not try switching it with the keyboard controller, check it. Lastly try the fast A20 way.
;
[bits 16]

%ifndef __A20_INC_INCLUDED__
%define __A20_INC_INCLUDED__

%include 'libs/common.inc'

;_________________________________________________________________________________________________________________________/ ϝ check_a20
;   Description:
;   This function checks if the A20 gate is already enabled by the BIOS, if so it is not necessary to do it again.
;
;   Returns:
;   ax      0 If the A20 gate is disabled.
;           1 if the A20 gate is already enabled.
;
check_a20:
    pushf                               ; Save the EFLAGS register on stack.
    push ds                             ; Save the data segment.
    push es                             ; Save the extra segment.
    push di                             ; Save the data index.
    push si                             ; save the source index.

    cli                                 ; Disable external interrupts.

    xor ax, ax                          ; Clear the ax.
    mov es, ax                          ; Copy null to the extra segment.

    not ax                              ; Negate 0 to 0xFFFF
    mov ds, ax                          ; Set the data segment to 0xFFFF

    mov di, 0x0500                       ; Set the address of boot signature.
    mov si, 0x0510                       ; Set the address of the boot signature 1 MiB higher.

    mov al,byte [es:di]                 ; Get the value from es:di.
    push ax                             ; Store the value on to the stack.

    mov al, byte [ds:si]                ; Get the value from ds:si.
    push ax                             ; Store the value on to the stack.

    mov byte [es:di], 0x00              ; Set 0x00 in es:di
    mov byte [ds:si], 0xFF              ; Set 0xFF in ds:si

    cmp byte [es:di], 0xFF              ; Check if the es:di still is zero.

    pop ax                              ; Get the stored ds:si from the stack.
    mov byte [ds:si], al                ; And copy the lower bit of the value and store it into ds:si.

    pop ax                              ; Get the stored es:di from the stack.
    mov byte [es:di], al                ; And copy the lower bit of the value and store it into es:di.

    mov ax, 0                           ; Set the return code to zero in ax if the A20 line is disabled.
    je .return                          ; Check if the two values are the same, if so return a 0.

    mov ax, 1                           ; The values differ from each other so the A20 line is enabled.

    ; Return to the caller.
    .return:
        pop si                          ; Restore the segment index,
        pop di                          ; Data index,
        pop es                          ; Extra segment,
        pop ds                          ; Data segment
        popf                            ; and the EFLAGS registers there previous state.
        ret                             ; And return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ enable_a20_bios
;   Description:
;   This function checks if the bios supports the A20 instructions, if so it tries to get the current status. If
;   disabled it will call the enable A20 function with interrupt 0x15.
;
;   Returns:
;   ax      0 When the A20 gate is disabled.
;           1 When the A20 gate is already enabled.
;
enable_a20_bios:
    ; Test if BIOS interrupt 15 for switching A20 is supported.
    mov ax, A20_SUPPORT                 ; Get test A20 support command, 0x2403.
    int BIOS_INTERRUPT_MIC_SYS            ; Perform an miscellaneous system interrupt, 0x15.
    jb .a20_not_supported               ; When the A20 command isn't recognized it sets the carry flag so jump here.
    cmp ah, 0                           ; Check if there are error codes set by the interrupt in ax.
    jnz .a20_not_supported              ; If ah contains anything else than zero, something went wrong.

    ; Check the current status of the a20 gate.
    mov ax, A20_STATUS                  ; Get the query A20 status command, 0x2402.
    int BIOS_INTERRUPT_MIC_SYS            ; Perform an miscellaneous system interrupt, 0x15.
    jb .a20_status_unavailable          ; When the A20 command isn't recognized it sets the carry flag so jump here.
    cmp ah, 0                           ; Check if there are error codes set by the interrupt in ax.
    jnz .a20_status_unavailable         ; If ah contains anything else than zero, something went wrong.

    cmp al, 1                           ; Al contains the A20 status, 1 is enabled, 0 is disabled.
    jz .a20_status_activated            ; If al is 1 the A20 gate is enabled.

    ; Activate the A20 gate.
    mov ax, A20_ACTIVATE                ; Get the enable A20 command, 0x2401.
    int BIOS_INTERRUPT_MIC_SYS           ; Perform an miscellaneous system interrupt, 0x15.
    jb .a20_activation_failed           ; When the A20 command isn't recognized it sets the carry flag so jump here.
    cmp ah, 0                           ; Check if there are error codes set by the interrupt in ax.
    jnz .a20_activation_failed          ; If ah contains a non zero status the activation failed.

    .a20_status_activated:
        mov ax, 1                       ; Set the return code to 1, so the A20 gate is enabled.
        ret                             ; return to the caller.
    .a20_not_supported:
        ; TODO: write debug macros to log more specific error information.
    .a20_status_unavailable:
        ; TODO: write debug macros to log more specific error information.
    .a20_activation_failed:
        ; TODO: write debug macros to log more specific error information.
        mov ax, 0                       ; Set the return code to 0, so the A20 gate is disabled.
        ret                             ; return to the caller.

;_________________________________________________________________________________________________________________________/ ϝ enable_a20_keyboard
;   Description:
;   This function attempts to enable the A20 gate by writing to the PS/2 (keyboard) controller. It query's the keyboard
;   controllers status register and flips the A20 bit (second bit). This seems not very logical but in fact its...
;   quit illogical. The reason of this is that Intel's 8042 keyboard controller had one spare pin and they decided that
;   keyboard communication and CPU memory access configuration are a good combination.
;
enable_a20_keyboard:
    cli                                 ; Disable external interrupts.

    ; Disable the external PS/2 port, to prevent external interrupts from the keyboard.
    call .wait_ready_command            ; Wait until the controller is ready for an command.
    mov al, PS2_DISABLE                 ; Get the PS/2 command, disable ps/2 port.
    out PS2_IO_PORT_COMMAND, al         ; Send the command to the controllers command register.

    ; Call the read from the controller output port.
    call .wait_ready_command            ; Wait until the controller is ready for an command.
    mov al, PS2_R_CONTR_OUTPUT          ; Get PS/2 command, Read controller output port.
    out PS2_IO_PORT_COMMAND, al         ; Send the command to the controllers command register.

    ; Request the current PS/2 controller configuration. (Status register)
    call .wait_ready_data               ; Wait until the controller is ready for reading data.
    in al, PS2_IO_PORT_STATUS           ; Read data from the PS/2 data port into al.
    push eax                            ; Store the data on the stack.

    ; Call the write to the controller output port.
    call .wait_ready_command            ; Wait until the controller is ready for an command.
    mov al, PS2_W_BYTE_OUTPUT           ; Get PS/2 command, Write next byte to output port.
    out PS2_IO_PORT_COMMAND, al         ; Send the command to the controllers command register.

    ; Write configuration back to the controller with the A20 bit flipped positive.
    call .wait_ready_command            ; Wait until the controller is ready for an command.
    pop eax                             ; Get the stored configuration of the ps/2 controller.
    or al, 0x02                         ; Make the second bit a 1, this is A20 bit.
    out PS2_IO_PORT_COMMAND, al         ; Write the configuration back to the controller output port.

    ; Re-enable the external PS/2 port, so we are able to use an keyboard again.
    call .wait_ready_command            ; Wait until the controller is ready for an command.
    mov al, PS2_ENABLE                  ; Get PS/2 command, enable the PS/2 port.
    out PS2_IO_PORT_COMMAND, al         ; Send the command to the command register, re-enabling the PS/2 port.

    ; Re-enable external interrupts and return to the caller.
    call .wait_ready_command            ; Wait until the controller is ready, before re-enabling interrupts.
    sti                                 ; Re-enable external interrupts.
    ret

    ; Wait until the the PS/2 controller has cleared the command port, when cleared its ready to write to.
    .wait_ready_command:
        in al, PS2_IO_PORT_STATUS       ; Read the current status of the PS/2 controller status register.
        test al, 2                      ; Test if the second bit of the status register, 0 means empty and available to use.
        jnz .wait_ready_command         ; Loop until the controller writes an 0 (register empty) to the status register.
        ret                             ; The controller has cleared its command register, ready to receive a new one.

    ; Wait until the PS/2 controller has filled the data port, when filled its ready to read from.
    .wait_ready_data:
        in al, PS2_IO_PORT_STATUS       ; Read the current status of the PS/2 controller status register.
        test al, 1                      ; Test if the first bit of the status register, 0 means empty and available to use.
        jz .wait_ready_data             ; Loop until the controller writes an 1 (register filled) to the status register.
        ret                             ; The controller has filled its data register, ready to read from it.

;_________________________________________________________________________________________________________________________/ ϝ enable_a20_fast
;   Description:
;   This function attempts to enable the A20 line using a new fast A20 option that can quickly switch the A20 gate
;   without the need for slow loops like the ones written above. Unfortunately this method is not supported on every
;   system, and there is no reliable way to figure out if it has any other effects on a system.
;
enable_a20_fast:
    in al, 0x92                         ; Read from system control port.
    test al, 2                          ; Check the second bit.
    jnz .return                         ; If the A20 port is already enabled return.
    or al, 2                            ; Make the second bit positive.
    and al, 0xFE                        ; Flip the A20 configuration bits.
    out 0x92, al

    .return:
        ret                             ;

%endif ; __A20_INC_INCLUDED__
