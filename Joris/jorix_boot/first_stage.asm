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

start:
    jmp main      ; Jump to the initiation function that loads the second loader.
    nop
;
;   The BIOS Parameter Block
;
;   This data structure describes the the physical layout of the floppy drive image that is used to store the bootloader.
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

;   print_string
;
;   Description:
;   This function can be used to print an null terminated string to the screen using the BIOS Video service interrupts.
;   To use this function you should point the source index (SI register) to the starting address of the string you want to print.
;
;   Example Call:
;   my_str: db "Hello world", 0
;   mov     si, my_str
;   call    print_string
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

;   read_sectors
;
;   Description:
;   This function reads a series of sectors from a storage device to memory. It uses the cs, ax registers as arguments,
;   CX defines the amount of sectors it should read and AX defines the starting sector of the sector. ES:BX is used as
;   buffer that the read sectors should be written to.
;
read_sectors:
    .main:
        mov di, 0x0005  ; The amount of retries if an error occurs.
    .readAnSector:
        push ax                         ; Save ax, that contains the starting address of the sectors to read.
        push bx                         ; Save bx, that contains the address to copy the read sectors to.
        push cx                         ; Save cx, that contains the amount of sectors it should read.
        call convert_LBA_CHS            ; Get the correct register addresses.
        mov ah, 0x02
        mov al, 0x01
        mov ch, BYTE [absoluteTrack]    ; track
        mov cl, BYTE [absoluteSector]   ; sector
        mov dh, BYTE [absoluteHead]     ; head
        mov dl, BYTE [bsDriveNumber]    ; drive
        int 0x13                        ; invoke BIOS
        jnc .readedSuccessfull          ; test for read error
        xor ax, ax                      ; BIOS reset disk
        int 0x13                        ; invoke BIOS
        dec di                          ; decrement error counter
        pop cx                          ; Restore the state of the cx register.
        pop bx                          ; Restore the state of the bx register.
        pop ax                          ; Restore the state of the ax register.
        jnz .readAnSector               ; attempt to read again
        int 0x18                        ; Reset and try again.
    .readedSuccessfull:
        mov     si, msgProgress         ; Load a progress message to notify the user of an successful read.
        call    Print                   ; Print the message to the screen.
        pop     cx                      ; Restore the state of the cx register.
        pop     bx                      ; Restore the state of the bx register.
        pop     ax                      ; Restore the state of the ax register.
        add bx, word[bpbBytesPerSector] ; Queue the next buffer
        inc ax                          ; Increment the read counter
        loop .main                      ; Move ahead to the next sector to read.
        ret                             ; return

;   convert_CHS_LBA
;
;   This function converts CHS (Cylinder/Head/Sector) addressing to LBA (Logical Block Addressing).
;
convert_CHS_LBA:
    sub ax, 0x0002                      ; The zero base cluster number
    xor cx, cx                          ; Zero the counter register.
    mov cl, byte[bpbSectorsPerCluster]  ; Convert the byte to an word.
    mul cx                              ; Multiply cx with 2
    add ax, word[datasector]            ; Set the base data sector.
    ret                                 ; return to the caller.

convert_LBA_CHS:
    ret
;
; This is the entry point of the second stage bootloader.
;
main:
    load_root:
        ; Calculate the size of the root directory
        xor cx, cx                          ; Zero the counter register.
        xor dx, dx                          ; Zero the data register.
        mov ax, 0x0020                      ; Move the number 32 (the size of an FAT directory entry) to ax.
        mul word [bpbRootEntries]           ; Then multiply the size of each entry by the number of root entries.
        div word [bpbBytesPerSector]        ; Finally divide the number of root entries by the bytes each sector has to get the amount
                                            ; of bytes the root entry uses.
        xchg ax, cx                         ; exchange registers, so that cx contains the answer of the calculation and ax 0 for the next.

        ; Calculate the location of the root directory. (Remember the root directory is after: boot sector, extra reserved sectors, FAT 1 and FAT 2)
        mov al, byte[bpbNumberOfFATs]       ; First get the number of FAT's
        mul word[bpbSectorsPerFAT]          ; Then multiply that with the amount of sectors each FAT has.
        add ax, word[bpbReservedSectors]    ; Then add the reserved sectors (Like the bootloader) to get the amount of sectors before the root directory.
        mov word[datasector], ax            ; Set the starting point of the data sector to ax (Start of our code) to pass to the read sectors function.
        add word[datasector], cx            ; Finally add the starting address to the total size to get the total amount of segments to read.

        ; Read the root directory into memory at 7c00:0200 using the just calculated AX (starting point) and CX (Amount of sectors to read) as arguments.
        mov bx, 0x0200                      ; Define the location where the root directory should be loaded to, This is after the boot code (320 bytes)
        call read_sectors                    ; Call the function that actually reads sectors into memory.

        ; Find the location of the second stage of the bootloader located some where in the root directory.
        mov cx, word[bpbRootEntries]        ; Initiate the counter with the maximum amount of entries that exist in our root directory. This counter will
                                            ; be decremented until the correct entry is found or if we reach 0, which means that the file doesn't exist.
        mov di, 0x0200                      ; Set the pointer for comparing the each character in the second stage file name to the start of the root directory.
        .loopFilename:
            push cx                         ; Save the boot entry counter to the stack so it can be restored later.
            mov cx, 0x000B                  ; Initiate the counter with the number 11 (the required length of a FAT12 file name) so we can iterate through each
                                            ; character and compare it with the file name of the second stage of the bootloader.
            mov si, ImageName               ; Point the source for the compare operation to string that defines the file name of the second stage bootloader.
            push di                         ; Save the starting location of the current entry that is being compared, so we can recover it if the compare operation
                                            ; found a match. This is needed because the compare operation will increment and thus alter the index each iteration.
            rep cmpsb                       ; Repeat the string compare as long as the characters are the same or if the cx is at 0 which means the file is found.
            pop di                          ; Fetch the starting address of the entry just checked from the stack.
            je loadFAT                      ; Check if the last character compare operation has set the zero flag, if so we found the second stage file. Remember that 0
                                            ; means that there is an difference of 0 bits between comparing the characters.(cmpsb just subtracts di from si).
            pop cx                          ; Restore
            add di, 32                      ;
            loop .loopFilename              ;
            jmp failure                     ;

    loadFAT:
        mov si, msgCRLF                 ; Set the source pointer to the string to print.
        call print_string               ; print the string to notify the user
        mov dx, word[di+0x001A]         ;
        mov word[cluser], dx            ;

        xor ax, ax                      ; Zero the ax register.
        mov al, byte[bpbNumberOfFATs]   ; Get the number of file allocation tables.
        mul word[bpbSectorsPerFAT]      ; Then multiply them with the amount of sectors of each fat.
        mov cx, ax                      ; Save the answer to cx

        mov ax, word[bpbReservedSectors]; Adjust the location by adding the boot sector.

        mov bx, 0x0200                  ; Set the location to write the fat to.
        call read_sectors                ; Copy the file allocation table above the boot code at address 7c00:0200

        mov si, mesgCRLF                ; Set the source pointer to the string to print.
        call print_string               ; print the string to notify the user
        mov ax, 0x0050                  ;
        mov es, ax                      ; The destination for the image
        mov bx, 0x0000                  ; The destination for the image
        push bx                         ; push the destination to the stack.

    cli ; Clear all interrupts
    hlt ; Halt the execution.

;
; Some string contants.
;
STR_HELLO:  db "Welcome to Jorix OS", 0

times 510 - ($-$$) db 0     ; Fill all unused memory with zeros until the 510th byte.
dw 0xaa55                   ; Set the bootable flag at the 510th byte so the bios knows this sector is bootable.
