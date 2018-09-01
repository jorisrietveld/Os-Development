;
; Author: Joris Rietveld - <jorisrietveld@gmail.com>
; Github: <https://github.com/jorisrietveld>
; Date created: 29-08-2018 03:12
; Licence: GPLv3 - General Public Licence version 3 <https://www.gnu.org/licenses/gpl-3.0.txt>
;
; Description:
; This file includes the first stage bootloader that is responsible for initializing the CPU and loading the next stage
; of the bootloader into ram. The first stage of the bootloader is located on the first sector (Bootsector or MBR
; Master Boot Record) of an storage device.
; After the POST and BIOS have finished there part of the system initialization and testing. The BIOS starts looking for
; bootable devices to pass its control to. The BIOS reads from connected storage devices and will look
; for 2 "Magic" bytes that are written to the 511 and 512th bytes of the first sector.

; The two bytes at the end of the sector are either: 0xAA55 or 0x55AA depending if the system is big or little endian.
; It doesnt matter because the number converts to the exact same binary pattern: 1010 1010 0101 0101.
;
bits 16     ; Configure the assembler to assemble into 16 bit instructions (For 16 bit real-mode)

startFirstStage:
    ; Set the starting point of the code
    cli             ; Disable all hardware interrupts.
    mov ax, 0x7c0   ; Define the address of where the code should start.
    mov ds, ax      ; Adjust the data segment to the new location.
    mov es, ax      ; Adjust the extra segment to the new location.
    mov fs, ax      ; Adjust the  segment to the new location.
    mov gs, ax      ; Adjust the  segment to the new location.
