;__________________________________________________________________________________________/ Bios.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 06-01-2018 07:46
;   
;   Description:
;   This file defines easy to remember names for defining the BIOS interrupt services and arguments.
;
%ifndef __BIOS_INC_INCLUDED__
%define __BIOS_INC_INCLUDED__

%define BIOS_INTERRUPT_VIDEO      0x10    ; Video services, everything for displaying output on the screen.
%define BIOS_INTERRUPT_EQUIP_LST  0x11    ; Returns a list all all equipment.
%define BIOS_INTERRUPT_MEM_SIZE   0x12    ; Get the memory conventional size, quit hard to get in protected mode.
%define BIOS_INTERRUPT_DISK       0x13    ; Low level disk management, for controlling the hard disk, floppy or cd drives
%define BIOS_INTERRUPT_SERIAL     0x14    ; Serial Port Services, for serial communication between devices.
%define BIOS_INTERRUPT_MIC_SYS    0x15    ; Miscellaneous system services like: BIOS commands,
%define BIOS_INTERRUPT_KEYBOARD   0x16    ; Keyboard services for communication between the keyboard.
%define BIOS_INTERRUPT_PRINTER    0x17    ; Printer services for communication between printers.
%define BIOS_INTERRUPT_REBOOT     0x18    ; An (cold) reboot interrupt this will completely reset the computer.
%define BIOS_INTERRUPT_W_REBOOT   0x19    ; An warm reboot interrupt this will reset the computer but without wiping the RAM.

;  Miscellaneous system services
%define A20_ACTIVATE       0x2401      ; Enables the A20 gate with interrupt 15.
%define A20_STATUS         0x2402      ; Gets the current status of the A20 gate.
%define A20_SUPPORT        0x2403      ; Used to check if the CPU supports the BIOS int.

%endif ;__BIOS_INC_INCLUDED__
