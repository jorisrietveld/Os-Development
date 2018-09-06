;__________________________________________________________________________________________/ Floppy16.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 28-12-2017 14:48
;   
;   Description:
;   This is an 16 bit floppy disk driver written to control floppy disk drive devices.

%ifndef __FLOPPY16_ASM_INCLUDED__
%define __FLOPPY16_ASM_INCLUDED__
bits 16

;________________________________________________________________________________________________________________________/ § BIOS Parameter Block
;   Description:
;   The BPB (BIOS Parameter Block) is the data structure that describes the the physical layout of the device.
;
oem                 db "Jorix OS"   ; The name of the OS.
sectorSize  	    dw 512          ; The amount of bytes in a sector on the floppy disk.
clusterSize  	    db 1            ; The cluster size.
reservedSectors     dw 1            ; The amount of sectors that are not part of the FAT12 system.
amountOfFATs  	    db 2            ; The number of file allocate tables on the floppy disk.
maxRootEntries      dw 224          ; The maximum amount of entries in the root directory.
totalSectors  	    dw 2880         ; The amount of sectors that are present on the floppy disk.
mediaDescriptor     db 0x0F0        ; Media description settings.
fatSize  	        dw 9            ; The amount of sectors in each FAT entry.
trackSize  	        dw 18           ; The amount of sectors after each other on the floppy disk.
sides  	            dw 2            ; The amount of reading heads above each other on the floppy disk.
hiddenSectors  	    dd 0            ; The amount of sectors between the physical start of the disk and filesystem.
largeSectors        dd 0            ; The total amount of lage sectors.
driveNumber  	    db 0            ; 0 because this is the standard for floppy disks.
unused              db 9
bootSig  	        db 0x29         ; The boot signature of: MS/PC-DOS Version 4.0
serial 	            dd 0xa0a1a2a3   ; This gets overwritten every time the image get written.
volumeLabel  	    db "MOS FLOPPY "; The label of the volume.
filesystem  	    db "FAT12   "   ; The type of file system.

;________________________________________________________________________________________________________________________/ § Variables
;   Description:
;   Some global variables and compiler macros.
;
DataSector  dw 0x0000   ; data sector.
cluster     dw 0x0000   ; cluster.
absoluteSector db 0x00  ; Data sector in CHS (Cylinder Head Sector) addressing.
absoluteHead   db 0x00  ; Head in CHS (Cylinder Head Sector) addressing.
absoluteTrack  db 0x00  ; Track in CHS (Cylinder Head Sector) addressing.

%include 'libs/Common.asm'

;________________________________________________________________________________________________________________________/ ϝ convertCHStoLBA
;   Description:
;   This function is responsible for converting CHS(Cylinder/Head/Sector) addressing to LBA (Logical Block Addressing)
;   using the formula LBA = (cluster -2) * sectorPerCluster.
;
;   Function Arguments:
;   ax      Is used to pass the cluster number.
convertCHStoLBA:
    sub ax, 0x0002              ; Cluster number - 2
    xor cx, cx                  ; Clear the counter
    mov cl, byte[clusterSize]   ; Get the amount of sectors in a cluster.
    mul cx                      ; Multiply the cluster number minus 2 by the amount of sectors.
    add ax, word[DataSector]    ; And add the data sector offset to it.
    ret

;________________________________________________________________________________________________________________________/ ϝ convertLBAtoCHS
;   Description:
;   This function is responsible for converting LBA(Logical Block Addressing) to CHS(Cylinder/Head/Sector) and storing
;   it in the global variables. It does this by using the formulas:
;   Absolute sector     = (LBA / sectorPerTrack) + 1
;   Absolute head       = (LBA / sectorPerTrack) % numberOfHeads
;   Absolute track      = LBA / ( sectorPerTrack * numberOfHeads)
;
;   Function Arguments:
;   ax      The LBA address that needs to be converted to CHS.
;
convertLBAtoCHS:
    xor dx, dx                  ; Clear dx
    div word[trackSize]         ; Divide LBA by sectorPerTrack (the remainder is stored in dx).
    inc dl                      ; Add 1 to the modulus of LBA
    mov byte[absoluteSector], dl; Save the calculated absolute sector address
    xor dx, dx                  ; Clear the value.
    div word[sides]             ; Divide LBA by the number number of heads. (dx has the remainder)
    mov byte[absoluteHead], dl  ; Store the absolute head.
    mov byte[absoluteTrack], al ; Store the absolute track.
    ret

;________________________________________________________________________________________________________________________/ ϝ readSectors
;   Description:
;   This function reads sectors from the floppy drive and write them to RAM using the BIOS interrupt 0x13 (more info can
;   be found at the bottom of this file.
;
;   Function Arguments:
;   cx      Is used to pass the amount of sectors that should be read.
;   ax      Is used to pass the starting sector.
;   es:ebx  Is the buffer where the sectors will be read to.
;
readSectors:
    .start:
        mov di, 0x0005  ; Set an limited amount of retries.

    ;______________________________________ Sector Read Iteration_________________________________________
    ; Convert the address to chs and execute interrupt 0x13 to load n(cx) amount of sectors from the disk.
    .readSector:
        push ax
        push bx
        push cx
        call convertLBAtoCHS            ; Convert the first sector to CHS.
        mov ah, 0x02                    ; Set the BIOS read sector argument for int 0x13
        mov al, 0x01                    ; Set the BIOS read sector amount to 1 for reading 1 sector.
        mov ch, byte[absoluteTrack]     ; Set the track
        mov cl, byte[absoluteSector]    ; Set the sector
        mov dh, byte[absoluteHead]      ; Set the head
        mov dl, byte[driveNumber]       ; Set the drive to use.
        int BIOS_INT_DISK               ; Use the BIOS interrupt to read 1 sector
        jnc .finished                   ; Check if there were no errors. (the BIOS will set the carry flag on error)

        ; Error reading the sector
        xor ax, ax                      ; Clear ax, 0x0 is the bios reset disk instruction.
        int BIOS_INT_DISK               ; Execute the reset disk using the BIOS interrupt.
        dec di                          ; Reading the sector failed so subtract 1 from the maximum retry amount.
        pop cx
        pop bx
        pop ax
        jnz .readSector                 ; If the retry amount is above 0 try reading the sector again.
        int BIOS_INT_REBOOT             ; It failed 5 times... reboot the system.
    ;______________________________________ Read success _________________________________________
    ; Convert the address to chs and execute interrupt 0x13 to load n(cx) amount of sectors from the disk.
    .finished:
        pop cx
        pop bx
        pop ax
        add bx, word[sectorSize]        ; Queue the next buffer.
        inc ax                          ; Queue the next sector.
        loop .start                     ; Jump to the top read the next sector.
        ret                             ; All sectors are read from the device return to the caller.

%endif ; __FLOPPY16_ASM_INCLUDED__

;
;                               + ADDITIONAL INFORMATION REFERENCED IN THE CODE ABOVE.
;
;________________________________________________________________________________________________________________________/ ℹ BIOS interrupt 0x13
;   Extra info about reading sectors from the floppy drive and write them to RAM using the BIOS interrupt 0x13.
;   0x13 is for low lever disk services and takes a few arguments listed below:
;   AH      is used to set the instruction to execute 0x02 is the read sector instruction
;   AL      is used to pass the amount of sectors to read.
;   CH      is used to pass the low eight bits of the cylinder number.
;   CL      is used to pass the sector number
;   DH      is used to pass the drive number
;   ES:BX   is used as an buffer to write the sectors to.
;   The 0x13 interrupt also alters AH, AL registers and the CF (Carry flag)
;   AH      Is used to store the status code.
;   AL      Is used to return the number of sectors that ware read.
;   CF      Will be cleared if the action was successful and set if not.
