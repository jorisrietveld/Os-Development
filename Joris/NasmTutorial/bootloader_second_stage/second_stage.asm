;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This file contains the second stage of the bootloader. This code gets
;   executed by the fist stage bootloader located in the first sector of the
;   disk. This stage of the bootloader is responsible for loading the kernel
;   of Jorix OS.
;
org 0x00    ; Offset to address 0
bits 16     ; Assemble to 16 bit instructions (For 16 bit real-mode)

jmp main    ; Jump to the main label.


;
; This is the entry point of the second stage bootloader.
;
main:
