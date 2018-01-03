;_________________________________________________________________________________________________________________________/ Fat12.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 28-12-2017 14:43
;   
;   Description:
;   This file contains code for using the File Allocation Table 12 (FAT12) file system that is used on 3.5 floppies.
;

%ifndef __FAT12_ASM_INCLUDED__
%define __FAT12_ASM_INCLUDED__
bits 16

%include "./libs/stdio.asm"
%include "./libs/Floppy16.asm"

%define     ROOT_OFFSET     0x02E00 ; The location to load the root directory table and FAT.
%define     FAT_SEGMENT     0x2C0   ; The location to load the fat in the segment registers.
%define     ROOT_SEGMENT    0x2C0   ; The location to load the root directory in the segment registers.



;________________________________________________________________________________________________________________________/ ϝ loadRootDirectory
;   Description:
;   This function is responsible for loading the root directory described in the FAT to location 0x7E00. This is the
;   the memory address located right above the bootloader code.
;
loadRootDirectory:
    pusha       ; Store all registers.
    push es     ; Make copy of the extra segment.

    ; Calculate the size of the root directory.
    xor cx, cx                      ; Clear the counter.
    xor dx, dx                      ; Clear the data.
    mov ax, 0x20                    ; Set the size of each FAT12 entry (32 byte)
    mul word[maxRootEntries]        ; Multiply that by the amount of entries there are.
    div word[sectorSize]            ; And divide it by the size of each sector to get the amount sectors.
    xchg ax, cx                     ; Store the result (number of sectors) located in cx in the ax register.

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
;   This function is responsible for loading the file allocation table from the disk in to memory.
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
    call readSectors                ; Read the sectors from disk
    pop es                          ; And restore the extra segment to its previous state.
    popa                            ; Also restore all the other CPU registers.
    ret                             ; The FAT is loaded

;________________________________________________________________________________________________________________________/ ϝ findFile
;   Description:
;   This function is responsible for searching for a file by its filename stored in the root table and returning the
;   root directory storage index index. Each FAT12 entry is exactly 32 bytes long and that the first 8 bytes contain the
;   file name followed by 3 bytes for the file extension. More info about FAT12 can be found at the bottom of this file.
;
;   Function Arguments:
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
    mov cx, word[maxRootEntries]    ; Set the loop counter with the maximum amount of entries in the root directory.
    mov di, ROOT_OFFSET             ; Locate the first root entry at the 1 MB mark.
    cld                             ; Clear the direction flag so string operations will increment de si:di registers.

    ;_______________________ Root Directory Entry iteration ______________________
    ; Check if there is an entry in the root directory that matches the file name.
    .checkEntry:
        push cx                     ; Save root directory counter so we can use the counter register for iterating over
        mov cx, 0x000B              ; the file names in the root directory. Each file name is 11 characters long.
        mov si, bx                  ; Set the file name to the si that will be used for string comparing.
        push di                     ; Store the starting index of the file name entry.
        rep cmpsb                   ; Iterate over stored entry and compare it with the file name. Remember cmpsb will
                                    ; subtract si from di, if the characters are equal the answer should be 0 and the
                                    ; zero flag will be set. Rep will execute string instructions n times stored in cx.
        pop di                      ; Get the directory index and store it to the stack so we can receive it on match.
        je .found                   ; if each cmpsb matched then the zero flag is set. Else:
        pop cx                      ; Get the root directory index.
        add di, 0x20                ; Add 32 to the destination index so it contains the next directory entry.
        loop .checkEntry            ; Do this action until the file is found and if there are entries left to check.

    ;_______________________ Return Error ________________________
    ; No entry found that matches the file name, return status -1.
    .notFound:
        mov si, debugMessage
        call printString16
        pop bx                      ; Restore the base,
        pop dx                      ; data and
        pop cx                      ; counter registers from stack.
        mov ax, -1                  ; Then set the return index to -1 which signals an error.
        ret                         ; Return to the caller.

    ;_______________________ Return Success ________________________
    ; No entry found that matches the file name, return status -1.
    .found:
        pop ax                      ; Get the found directory file index from the stack.
        pop bx                      ; Restore the base,
        pop dx                      ; data and
        pop cx                      ; counter registers from stack.
        ret                         ; Return to the caller.

;________________________________________________________________________________________________________________________/ ϝ loadFile
;   Description:
;   This function is responsible for locating and loading a file.
;
;   Function Arguments:
;   es:si       An string that contains the file name to search for in the root table.
;   bx:bp       An buffer to load the file to.
;
;   Returns:
;   ax          The status code, 0 means the file successfully loaded, -1 if there was an error.
;   cx          The amount of sectors that were loaded.
;
loadFile:
    xor ecx, ecx                    ; First set the counter to 0.
    push ecx                        ; And store it.

    ;________________________ Locate File __________________________
    ; use find file to get the file index to load, return status -1.
    .searchForFile:
        push bx                     ;
        push bp                     ; Store the storage buffer pointer.
        call findFile               ; Locate index of the file on disk, store result in ax.
        cmp ax, -1                  ; Check for error.
        jne .loadFilePreparation   ; No errors found jump over error handling.

        ; Error handling.
        pop bp                      ; Restore the base pointer,
        pop bx                      ; base,
        pop ecx                     ; extended counter registers from stack.
        mov ax, -1                  ; Set the status code to -1 to signal an error.
        ret
    ;_______________________ Return Success ________________________
    ; No entry found that matches the file name, return status -1.
    .loadFilePreparation:
        sub edi, ROOT_OFFSET
        sub eax, ROOT_OFFSET

        ; Get the starting cluster.
        push word ROOT_SEGMENT      ; Push the root segment address to stack.
        pop es                      ; and copy it to the extra segment.
        mov dx, word[es:di + 0x001A]; Get the files first cluster, es:di contains the FAT entry index after calling the
                                    ; find file function. The 2 byes(word) in the FAT entry at 0x1A (bytes 26-27) are
                                    ; used to store the first cluster. More info at end of this file.
        mov word[ cluster ], dx     ; Store it in the cluster variable.
        pop bx                      ; Get the location to write to stored on the stack.
        pop es                      ;
        push bx                     ; Store the location for later usage.
        push es                     ;
        call loadFAT                ; Now the first cluster is known load the FAT.

    .loadFile:
        mov ax, word[cluster]       ; Prepare converting the file starting cluster to LBA.
        pop es                      ; Get the cluster to read.
        pop bx                      ;
        call convertCHStoLBA        ; Convert the cluster to LBA (Logical Block Addressing)
        xor cx, cx                  ; Prepare reading the sectors, clear the counter.
        mov cl, byte[clusterSize]   ; The argument for readSectors that defines the amount of sectors to read.
        call readSectors            ; Read the sectors.
        pop ecx                     ; Get the sector counter from stack and
        inc ecx                     ; increment it.
        push ecx                    ; Then store it again.

        ; Save the registers for next iteration.
        push bx
        push es

        mov ax, FAT_SEGMENT         ; Get the FAT segment offset.
        mov es, ax                  ; move the extra segment to it.
        xor bx, bx                  ; Clear the base register.

        ; Load the next cluster and Determine if the cluster is odd or even.
        mov ax, word[cluster]       ; Identify the current cluster from the file allocation table.
        mov cx, ax                  ; Copy the current cluster.
        mov dx, ax                  ; Make a temporary copy to the data register so we can use it in a calculation.
        shr dx, 0x0001              ; Divide by 2 using an logical right shift of 1
        add cx, dx                  ; Sum the values (3/2)

        mov bx, 0                   ; Set the data register to the address of the file allocation table.
        add bx, cx                  ; Add the current index to the FAT base address.
        mov dx, word[es:bx]         ; Read 2 bytes from the file allocation table.
        test ax, 0x0001             ; Test the bit pattern 0001 on the cluster.
        jnz .oddCluster             ; If the bit pattern didn't match its a odd cluster, jump to the routine that handles them.

        ; If the cluster is even, then take the 12 low bits.
        .evenCluster:
            and dx, 0b0000111111111111  ; Take the low 12 bits
            jmp .finishedCluster    ; And jump to the finished routine.

        ; If the cluster is odd, then take the high 12 bits.
        .oddCluster:
            shr dx, 0x0004          ; Take the high 12 bits.

        ; Then check if the sizes are correct.
        .finishedCluster:
            mov word[cluster], dx   ;
            cmp dx, 0x0ff0          ; Compare the data register to 4080 (Constant for end of file marker)
            jb loadFile             ; Move to the next

        .success:
            pop es                  ; Restore the extra segment.
            pop bx                  ; And restore the base and
            pop ecx                 ; extended counter registers.
            xor ax, ax              ; Set the status code to 0 meaning success.
            ret

debugMessage db "Error is here.", 0

%endif ; __FAT12_ASM_INCLUDED__

;
;                               + ADDITIONAL INFORMATION REFERENCED IN THE CODE ABOVE.
;
;________________________________________________________________________________________________________________________/ ℹ FAT12 entry
;   Description:
;   The table below shows the components that make up an FAT12(File Allocation Table 12) entry. Each entry is exactly
;   32 bytes in length. If any of bytes described are unused they should be padded, not doing so will corrupt the
;   filesystem making it useless and possibly vulnerable.
;
;   ________________________________FAT 12 TABLE ENTRY STRUCTURE _______________________________________
;   Bytes:  Bits:   Description:
;   0-7             The name of the file, padded with spaces.
;   8-10            The file extension, padded with spaces.
;   11              File attributes bit pattern:
;           0       Read only file flag.
;           1       Hidden file flag.
;           2       System file flag.
;           3       Volume label flag.
;           4       This is a sub directory flag.
;           5       Archive flag.
;           6       Device flag.
;           7       unused.
;   12              unused in FAT12.
;   13              Created time fine resolution in 10 millisecond units. Range 0-199
;   14-15           Created time encoded in the following format:
;           0-4     Seconds divided by 2 (range 0-29)
;           5-10    Minutes (range 0-59)
;           11-15   Hours (range 0-23)
;   16-17           Created year encoded in the following format:
;           0-4     Day (range 1-31)
;           5-10    Month (range 1-31)
;           11-15   Year started counting from 1980 (range 0-199)
;   18-19           Last access date in the following format:
;           0-4     Day (range 1-31)
;           5-10    Month (range 1-31)
;           11-15   Year started counting from 1980 (range 0-199)
;   20-21           Used for Extended Attributes (can be ignored)
;   22-23           Last modified time in the following format:
;           0-4     Seconds divided by 2 (range 0-29)
;           5-10    Minutes (range 0-59)
;           11-15   Hours (range 0-23)
;   24-25           Last modified date in the following format:
;           0-4     Day (range 1-31)
;           5-10    Month (range 1-31)
;           11-15   Year started counting from 1980 (range 0-199)
;   26-27           The files first cluster.
;   28-32           The File size.
