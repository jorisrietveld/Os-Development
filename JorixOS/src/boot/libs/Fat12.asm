;_________________________________________________________________________________________________________________________/ Fat12.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 28-12-2017 14:43
;   
;   Description:
;   This file contains code for using the File Allocation Table 12 (FAT12) file system that is used on 3.5 floppies.
;

%ifndef __FAT12_ASM_INCLUDED
%define __FAT12_ASM_INCLUDED
bits 16

%include "Floppy16.asm"

%define     ROOT_OFFSET     0x02E00 ; The location to load the root directory table and FAT.
%define     FAT_SEGMENT     0x2C0   ; The location to load the fat in the segment registers.
%define     ROOT_SEGMENT    0x2C0   ; The location to load the root directory in the segment registers.

;________________________________________________________________________________________________________________________/ ϝ loadRoot
;   Description:
;   This function is responsible for loading the root directory described in the FAT.
;
loadRoot:
    pusha       ; Store all registers.
    push es     ; Make copy of the extra segment.

    ; Calculate the size of the root directory.
    xor cx, cx                      ; Clear the counter.
    xor dx, dx                      ; Clear the data.
    mov ax, 0x20                    ; Set the size of each tables entry (32 byte)
    mul word[maxRootEntries]        ; Multiply that by the amount of entries there are.
    div word[sectorSize]            ; And divide it by the size of each sector to get the amount sectors.
    xchg ax, cx                     ; Store the result in cx

    ; Calculate the location of the root directory and store it in ax
    mov al, byte[amountOfFATs]      ; Get the amount of fats on the disk.
    mul word[fatSize]               ; multiply it by the size of each fat.
    add ax, word[reservedSectors]   ; And add the amount of reserved sectors (like the bootloader)
    mov word[datasector], ax        ; Store the address of the data sector.
    add word[datasector], cx        ; Add the size of the root directory.

    ; Read the root directory into 0x7c00
    push word ROOT_SEGMENT          ; Push the root segment addess on to the stack.
    pop es                          ; Pop the extra segment from the stack.
    xor bx, bx                      ; Set the address to 0
    call readSectors                ; Call the function that copies all sectors from the disk to ram.
    pop es                          ; Remove extra segment from stack.
    popa                            ; Restore all registers.
    ret
;________________________________________________________________________________________________________________________/ ϝ loadFAT
;   Description:
;   This function is responsible for loading the file allocation table over the bootloader code that is no longer needed.
;
;   Function Arguments:
;   es:di       The root directory table location.
loadFAT:
    pusha                           ; Store all registers
    push es                         ; Store the extra segment.

    ; Calculate the size of the FAT and store it in the counter register (cx)
    xor ax, ax                      ; Clear ax
    mov al, byte[amountOfFATs]      ; Get the number of fats
    mul word[fatSize]               ; Multiply that by the amount of sectors in each FAT.
    mov cx, ax                      ; Store the value in cx

    ; Calculate the location of the FAT and store in the accumulator (ax)
    mov ax, word[reservedSectors]   ; Get the amount of reserved sectors (like bootloader)

    ; Read the FAT into memory at location 0x7c00 so it will overwrite the bootloader code.
    push word FAT_SEGMENT           ; Store the segment location on to the stack.
    pop es                          ; And set it to the extra segment.
    xor bx, bx                      ; Clear the base register.
    call ReadSectors                ; Read the sectors.
    pop es                          ; And restore the extra segment to its previous state.
    popa                            ; Also restore all the other CPU registers.
    ret                             ; The FAT is loaded

;________________________________________________________________________________________________________________________/ ϝ findFile
;   Description:
;   This function is responsible for searching for a file name stored in the root table.
;
;   Arguments:
;   ds:si       An string that contains the file name to search for in the root table.
;
;   Returns:
;   ax          The file index number in the root directory table or -1 on error.
;
findFile:
    push cx                         ; Store the registers to the stack: the counter register.
    push dx                         ; the data register.
    push bx                         ; and finally the base register.
    mov bx, si                      ; Move the source index containing the file name to the base register.
    mov cx, word[maxRootEntries]    ; Initiate the counter with the maximum amount of root entries.
    mov di, ROOT_OFFSET             ; Locate the first root entry at the 1 MB mark.
    cld                             ; Clear the direction flag so string operations will increment de si:di registers.

    ;_____________ Character Loop iteration _______________
    ;
    .checkEntry
        push cx                     ; Save root directory counter so we can use the counter register for iterating over
        mov cx, 0x000B              ; the file names in the root directory. Each file name is 11 characters long.
        mov si, bx                  ; Set the file name to the si that will be used for string comparing.
        push di                     ; Store the starting index of the file name entry.
        rep cmpsb                   ; Iterate over stored entry and compare it with the file name. Remember cmpsb will
                                    ; subtract si from di, if the characters are equal the answer should be 0 and the
                                    ; zero flag will be set. Rep will execute string instructions n times stored in cx.
        pop di                      ; Get the starting address.
        je .found                   ; if each cmpsb matched then the zero flag is set. Else:
        pop cx                      ; Get the root directory index.
        add di, 0x20                ; Add 32 to the destination index so it contains the next directory entry.
        loop .checkEntry            ; Do this action until the file is found and if there are entries left to check.

    .notFound:
        pop bx
        pop dx
        pop cx
        mov ax, -1
        ret

    .found:
        pop ax
        pop bx
        pop dx
        pop cx
        ret

loadFile:
    xor ecx, ecx
    push ecx

    .searchForFile:
        push bx
        push bp
        call findFile
        cmp ax, -1
        jne .loadImagePreparation
        pop bp
        pop bx
        pop ecx
        pop ax, -1
        ret

    .loadImagePreparation:
        sub edi, ROOT_OFFSET
        sub eax, ROOT_OFFSET

        push word ROOT_SEGMENT
        pop es
        mov dx, word[es:di + 0x001A]
        mov word[ cluster ], dx
        pop bx
        pop es
        push bx
        push es
        call loadFat

    .loadImage:
        mov ax, word[cluster]
        pop es
        pop bx
        call convertCHStoLBA
        xor cx, cx
        mov cl, byte[clusterSize]
        call readSectors
        pop ecx
        inc ecx
        push ecx
        push bx



%endif
