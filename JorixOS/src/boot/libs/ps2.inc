;__________________________________________________________________________________________/ ps_2.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 08-06-2018 09:10
;   
;   Description:
;   The 8042 ps/2 controller (aka keyboard controller) communicates with ps/2 devices like a keyboard and
;   mouse. But its also used for other things like parity error correction, sound, system resets and for
;   controlling the A20 gate.
;
%ifndef __PS2_INC_INCLUDED__
%define __PS2_INC_INCLUDED__

; Constants with PS/2 IO ports.
%define PS2_IO_PORT_DATA 0x60           ; Reads/Writes to the data port.
%define PS2_IO_PORT_STATUS 0x64         ; Reads from the controllers status register.
%define PS2_IO_PORT_COMMAND 0x64        ; Writes to the controllers command register.

%define PS2_DISABLE_SECOND 0xA7         ; Disables the second PS/2 port, if two ports are supported.
%define PS2_ENABLE_SECOND 0xA8          ; Enables the second PS/2 port, if two ports are supported.
%define PS2_TEST_SECOND 0xA9            ;
%define PS2_TEST_CONTR 0xAA             ;
%define PS2_TEST_PORT 0xAB              ;
%define PS2_DIAG_DUMP 0xAC              ;
%define PS2_DISABLE 0xAD                ;
%define PS2_ENABLE 0xAE                 ;
%define PS2_READ_CONTROLR_INPUT 0xC0    ;
%define PS2_CP_INP_BIT_03_STAT 0xC1     ;
%define PS2_CP_INP_BIT_47_STAT 0xC2     ;
%define PS2_R_CONTR_OUTPUT 0xD0         ;
%define PS2_W_BYTE_OUTPUT 0xD1          ;
%define PS2_W_BYTE_SECOND_OUTPUT 0xD2   ;
%define PS2_W_BYTE_SECOND_INPUT 0xD3    ;

%endif ; __PS2_INC_INCLUDED__
