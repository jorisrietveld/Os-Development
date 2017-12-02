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
jmp loader      ; Jump to the initiation function that loads the second loader.
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
bpbSectorsPerTrack: 	dw 18           ; The amount of sectors after each other on the floppy disk.
bpbHeadsPerCylinder: 	dw 2            ; The amount of reading heads above each other on the floppy disk.
bpbHiddenSectors: 	    dd 0            ; The amount of sectors between the physical start of the disk and the start of the volume.
bpbTotalSectorsBig:     dd 0            ;
bsDriveNumber: 	        db 0            ; 0 because this is the standard for floppy disks.
bsUnused: 	            db 0            ; We are using everything on the floppy disk.
bsExtBootSignature: 	db 0x29         ; The boot signature of: MS/PC-DOS Version 4.0
bsSerialNumber:	        dd 0xDEADC0DE   ; This will get overwritten every time the image get written so it doesn't matter.
bsVolumeLabel: 	        db "JORUX OS   "; The label of the volume.
bsFileSystem: 	        db "FAT12   "   ; The type of file system.

;
; Some string contants.
;
STR_HELLO:  db "Welcome to Jorix OS", 0

;
; Prints a string to the screen.
;
print_string:
    pusha   ; Save the current registers states of the CPU before altering them in this function.

    .print_character:
        ; Load Data segment Byte
        lodsb       ; Load byte from string element addressed by DS:SI to the accumulator low register. The Direction Flag is clear
                    ; so SI (source index) is incremented so we can get the next character if we need to print more characters.
        or al, al   ; Do fast logical OR on the low byte of the accumulator low byte (containing an char of the string)
        jz .return  ; Done printing, the if the loaded byte contains an zero the or will set the zero flag.

        mov ah, 0x0e; Set the ASCII SO (shift out) character to the high byte of the accumulator.
        int 0x10    ; Fire an BIOS interrupt 16 (video services) that uses ax as its input, the high part of the accumulator register
                    ; contains an ASCII SO character this will determine the video function to perform. The low byte contains the
                    ; argument of that function (a character), so combined it will shift out(ah) the character stored in al.

        jmp .print_character ; Finished printing this character move to the next.

    .return:
        popa    ; Restore the state of the CPU registers to before executing this function.
        ret     ; The string is printed and the registers are restored so go back to the caller.
;
; This is the entry point of the second stage bootloader.
;
loader:
    .reset:
    mov ah, 0   ; The accumulator high byte contains the function to execute, function 0 resets the drive.
    mov dl, 0   ; The data segment contains the drive number, so 0 for the floppy drive.
    int 0x13    ; Fire an low level disk service interrupt that uses ah as function and dl to select an drive.
    jc .reset   ; Reset again if the carry flag is set, the carry flag gets set by the bios interrupt when an error occurs.

    mov ax, 0x1000  ; We are going to read in the sector at address 0x1000:0
    mov es, ax      ; Set the extra segment register to that address.
    xor bx, bx      ; Set the base register to 0 (using xor because it is faster than a: mov bx, 0)

    mov ah, 0x02    ; The ax high byte contains the function to execute, 2 reads an segment.
    mov al, 1       ; The ax low byte contains the argument to pass, pass 1 for 1 sector.

    xor ax, ax  ; Zero the accumulator register. (using xor because is it faster than an copy operation like: mov ax, 0)
    mov ds, ax  ; Set data segment to 7c00:0
    mov es, ax  ; Set extra segment to 7c00:0


    mov si, STR_HELLO   ; Point the segment index to the hello string.
    call print_string   ; Call the print function that outputs the data in segment index register.

    xor ax, ax  ; Zero the accumulator register again.
    int 0x12    ; Get the amount of KB from the bios into the accumulator.

    cli ; Clear all interrupts
    hlt ; Halt the execution.



times 510 - ($-$$) db 0     ; Fill all unused memory with zeros until the 510th byte.
dw 0xaa55                   ; Set the bootable flag at the 510th byte so the bios knows this sector is bootable.
