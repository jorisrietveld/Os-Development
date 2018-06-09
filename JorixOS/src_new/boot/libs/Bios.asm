;__________________________________________________________________________________________/ Bios.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 06-01-2018 07:46
;   
;   Description:
;   This file contains some macro constants for defining the BIOS interrupt services.
%ifndef __BIOS_ASM_INCLUDED__
%define __BIOS_ASM_INCLUDED__

%define BIOS_INT_VIDEO      0x10        ; Video services, everything for displaying output on the screen.
%define BIOS_INT_EQUIP_LST  0x11        ; Returns a list all all equipment.
%define BIOS_INT_MEM_SIZE   0x12        ; Get the memory conventional size, quit hard to get in protected mode.
%define BIOS_INT_DISK       0x13        ; Low level disk management, for controlling the hard disk, floppy or cd drives
%define BIOS_INT_SERIAL     0x14        ; Serial Port Services, for serial communication between devices.
%define BIOS_INT_MIC_SYS    0x15        ; Miscellaneous system services like: BIOS commands,
%define BIOS_INT_KEYBOARD   0x16        ;
%define BIOS_INT_PRINTER    0x17        ;
%define BIOS_INT_REBOOT     0x18        ;
%define BIOS_INT_W_REBOOT   0x19        ;

%endif ;__BIOS_ASM_INCLUDED__
