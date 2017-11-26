;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;   This file contains the fist stage of the bootloader. Because of the size
;   constrains of 512 bytes this loader is only responsible for setting up
;   some basic functions and initiating an second stage bootloader that will
;   start the kernel.
;
bits 16         ; Configure the assembler to compile into 16 bit instructions (For 16 bit real-mode)
org 0x7c00      ; Memory offset to address 0x7c00, so we don't overwrite the BIOS interrupt vectors.
jmp init_loader ; Jump to the initiation function that loads the second loader.
nop             ; Do nothing

;
; BPB - The BIOS Parameter Block
; This data structure describes the physical layout of the storage volume.
;
osName:                 db "Jorix OS"   ; The name of the OS, Must be stored at 0x03 to 0x0A (with 0x7c00 prefix)
bpbBytesPerSector:  	dw 512          ; The amount of bytes in a sector on the floppy disk.
bpbSectorsPerCluster: 	db 1            ; The cluster size, 1 sector because we need to be able to allocate 512 bytes.
bpbReservedSectors: 	dw 1            ; The amount of sectors that are not part of the FAT12 system, 1 that is the boot sector.
bpbNumberOfFATs: 	    db 2            ; The number of file allocate tables on the floppy disk (standard 2 for FAT12)
bpbRootEntries: 	    dw 224          ; The maximum amount of entries in the root directory.
bpbTotalSectors: 	    dw 2880         ; The amount of sectors that are present on the floppy disk.
bpbMedia: 	            db 0b11110000   ; Media description settings (single sided, 9 sectors per FAT, 80 tracks, and not removable)
bpbSectorsPerFAT: 	    dw 9            ; The amount of sectors in each FAT entry.
bpbSectorsPerTrack: 	DW 18           ; The amount of sectors after each other on the floppy disk.
bpbHeadsPerCylinder: 	DW 2            ; The amount of reading heads above each other on the floppy disk.
bpbHiddenSectors: 	    DD 0            ; The amount of sectors between the physical start of the disk and the start of the volume.
bpbTotalSectorsBig:     DD 0            ;
bsDriveNumber: 	        DB 0            ; 0 because this is the standard for floppy disks.
bsUnused: 	            DB 0            ; We are using everything on the floppy disk.
bsExtBootSignature: 	DB 0x29         ; The boot signature of: MS/PC-DOS Version 4.0
bsSerialNumber:	        DD 0xDEADC0DE   ; This will get overwritten every time the image get written so it doesn't matter.
bsVolumeLabel: 	        DB "JORUX OS   "; The label of the volume.
bsFileSystem: 	        DB "FAT12   "   ; The type of file system.

;
;
;
print_string:
    ; Load Data segment Byte
    lodsb       ; Load byte from string element addressed by DS:SI to the accumulator. The Direction Flag is clear so SI is incremented.
    or al, al   ; Do fast logical OR on the low byte of the accumulator (containing an char of the string)
    jz

;
; This is the entry point of the second stage bootloader.
;
init_loader:

