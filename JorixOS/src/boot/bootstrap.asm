;                                                                                       ,   ,           ( VERSION 0.0.2
;                                                                                         $,  $,     ,   `̅̅̅̅̅̅( 0x002
;                                                                                         "ss.$ss. .s'          `̅̅̅̅̅̅
;   MMMMMMMM""M MMP"""""YMM MM"""""""`MM M""M M""MMMM""M                          ,     .ss$$$$$$$$$$s,
;   MMMMMMMM  M M' .mmm. `M MM  mmmm,  M M  M M  `MM'  M                          $. s$$$$$$$$$$$$$$`$$Ss
;   MMMMMMMM  M M  MMMMM  M M'        .M M  M MM.    .MM    .d8888b. .d8888b.     "$$$$$$$$$$$$$$$$$$o$$$       ,
;   MMMMMMMM  M M  MMMMM  M MM  MMMb. "M M  M M  .mm.  M    88'  `88 Y8ooooo.    s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
;   M. `MMM' .M M. `MMM' .M MM  MMMMM  M M  M M  MMMM  M    88.  .88       88   s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
;   MM.     .MM MMb     dMM MM  MMMMM  M M  M M  MMMM  M    `88888P' `88888P'   s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
;   MMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMMM MMMM MMMMMMMMMM                       s$$$$$$$$$$'         `"""ss"$"$s""
;                                                                               s$$$$$$$$$$,              `"""""$  .s$$s
;   ______[  Author ]______    ______[  Contact ]_______                        s$$$$$$$$$$$$s,...               `s$$'  `
;      Joris Rietveld           jorisrietveld@gmail.com                       sss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
;                                                                             `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
;   _______________[ Website & Source  ]________________                           "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
;       https://github.com/jorisrietveld/Bootloaders                                 "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
;                                                                                     $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
;   ___________________[ Licence ]______________________                             $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
;             General Public licence version 3                                  ,   ,"     '  $$$$$$$$$$$$$$$$####s
;   ===============================================================================================================    ;
;                                                                                            First Stage Bootloader    ;                                                                                                                     ;
;   Description:                                                                             ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅    ;
;   This file contains the fist stage of the bootloader. Because of the memory size constrains of only 512 bytes,      ;
;   we have split the bootloader into two stages. One for setting up the minimal requirements of the system and a      ;
;   second one that can switch the CPU into protected mode and knows how to locate and start the operating system.     ;
;   This file contains the first stage that implements low lever routines for accessing and searching on storage       ;
;   devices that use the FAT12 (File Allocation Table) filesystem. This enables it to locate and eventually start      ;
;   the second part of the bootloader.                                                                                 ;
;                                                                                                                      ;
;   Created on: 17-12-2017 15:37                                                                                       ;
;                                                                                                                      ;
bits 16     ; Configure the assembler to assemble into 16 bit instructions (For 16 bit real-mode)

jmp short startFirstStage     ; Jump to the initiation function that loads the second loader.
nop                         ; Padding to align the bios parameter block.

;________________________________________________________________________________________________________________________/ § BIOS Parameter Block
;   Description:
;   The BPB (BIOS Parameter Block) is the data structure that describes the the physical layout of the
;   device, in our case a floppy drive image.
;
osName                  db "Jorix OS"   ; The name of the OS, Must be stored at 0x03 to 0x0A (with 0x7c00 prefix)
bpbBytesPerSector  	    dw 512          ; The amount of bytes in a sector on the floppy disk.
bpbSectorsPerCluster  	db 1            ; The cluster size, 1 sector because we need to be able to allocate 512 bytes.
bpbReservedSectors  	dw 1            ; The amount of sectors that are not part of the FAT12 system (boot sector).
bpbNumberOfFATs  	    db 2            ; The number of file allocate tables on the floppy disk (standard 2 for FAT12)
bpbRootEntries  	    dw 224          ; The maximum amount of entries in the root directory.
bpbTotalSectors  	    dw 2880         ; The amount of sectors that are present on the floppy disk.
bpbMedia  	            db 0x0F0        ; Media description settings:
                                        ; single sided, 9 sectors per FAT, 80 tracks, and not removable
                                        ; Explanation of the bits in the entry:
                                        ; Bit 0: Sides/Heads    = 0 if it is single sided, 1 if its double sided
                                        ; Bit 1: Size           = 0 if it has 9 sectors per FAT, 1 if it has 8.
                                        ; Bit 2: Density        = 0 if it has 80 tracks, 1 if it is 40 tracks.
                                        ; Bit 3: Type           = 0 for a fixed disk (HDD), 0 for a removable (FD,CD,USB)
                                        ; Bits 4 to 7 are unused, and always 1.
bpbSectorsPerFAT  	    dw 9            ; The amount of sectors in each FAT entry.
bpbSectorsPerTrack  	dw 18           ; The amount of sectors after each other on the floppy disk.
bpbHeadsPerCylinder  	dw 2            ; The amount of reading heads above each other on the floppy disk.
bpbHiddenSectors  	    dd 0            ; The amount of sectors between the physical start of the disk
                                        ; and the start of the volume.
bpbTotalSectorsBig      dd 0            ; The total amount of lage sectors.
bsDriveNumber  	        db 0            ; 0 because this is the standard for floppy disks.
bsExtBootSignature  	db 41           ; The boot signature of: MS/PC-DOS Version 4.0
bsSerialNumber 	        dd 0x00000000   ; This gets overwritten every time the image get written.
bsVolumeLabel  	        db "JORIX OS   "; The label of the volume.
bsFileSystem  	        db "FAT12   "   ; The type of file system.

%include "include/ascii.asm"
%include "include/bios.asm"
%include "include/global_variables.asm"

%define SEGMENT_OFFSET  0x7c0           ; Offset from where all code should start.
%define FAT_OFFSET      0x0200          ; Offset to load FAT to.

;________________________________________________________________________________________________________________________/ § main
;   Description:
;   This is the entry point of the stage bootloader. It will initiate the memory segments and stack, Then it executes
;   the routines that prepare the system for the booting the kernel.
;
startFirstStage:
    ; Set the starting point of the code
    cli                                 ; Disable all hardware interrupts.
    mov ax, SEGMENT_OFFSET              ; Define the address of where the code should start.
    mov ds, ax                          ; Adjust the data segment to the new location.
    mov es, ax                          ; Adjust the extra segment to the new location.
    mov fs, ax                          ; Adjust the  segment to the new location.
    mov gs, ax                          ; Adjust the  segment to the new location.

    ;Create the stack
    mov ax, 0x0000                      ; Set the location where the stack should be located.
    mov ss, ax                          ; Adjust the stack segment to the new location.
    mov sp, 0xffff                      ; Set the stack pointer to start at 0xffff (grows downwards)
    sti                                 ; Re-enable the interrupts.

    ; Greet the user
    mov si, msgLoading
    call printString

;________________________________________________________________________________________________________________________/ § loadRootDirectory
;   Description:
;   This function will load the root directory from the floppy disk to memory
;
loadRootDirectory:
    ; Calculate the size of the root directory
    xor cx, cx                          ; Zero the counter register.
    xor dx, dx                          ; Zero the data register.
    mov ax, 0x0020                      ; Move the number 32 (the size of an FAT directory entry) to ax.
    mul word [bpbRootEntries]           ; Then multiply the size of each entry by the number of root entries.
    div word [bpbBytesPerSector]        ; Finally divide the number of root entries by the bytes each sector has to get
                                        ; the amount of bytes the root entry uses.
    xchg ax, cx                         ; exchange registers, so that cx contains the answer of the calculation and
                                        ; ax 0 for the next.

    ; Calculate the location of the root directory. (It starts after: boot sector, extra reserved sectors, the 2 FAT's)
    mov al, byte[bpbNumberOfFATs]       ; First get the number of FAT's
    mul word[bpbSectorsPerFAT]          ; Then multiply that with the amount of sectors each FAT has.
    add ax, word[bpbReservedSectors]    ; Then add the reserved sectors (Like the bootloader) to get the amount of
                                        ; sectors before the root directory.
    mov word[datasector], ax            ; Set the starting point of the data sector to ax (Start of our code) to pass to
                                        ; the read sectors function.
    add word[datasector], cx            ; Finally add the starting address to the total size to get the total amount of
                                        ; segments to read.

    ; Read the root directory into memory at 7c00:0200 using AX (starting point) and CX (Amount of sectors to read).
    mov bx, FAT_OFFSET                  ; Define the location where the root directory should be loaded to, This is
                                        ; after the boot code (320 bytes)
    call readSectors                    ; Call the function that actually reads sectors into memory.

    ; Find the location of the second stage of the bootloader located some where in the root directory.
    mov cx, word[bpbRootEntries]        ; Initiate the counter with the maximum amount of entries that exist in our root
                                        ; directory. This counter will be decremented until the correct entry is found
                                        ; or if we reach 0, which means that the file doesn't exist.
    mov di, FAT_OFFSET                  ; Set the pointer for comparing the each character in the second stage file name
                                        ; to the start of the root directory.

    ;________________________________________ loopFilename _____________________________________________
    ; Loop through the FAT entries and test if the name matches the name of the second stage bootloader.
    .loopFilename:
        push cx                         ; Save the boot entry counter to the stack so it can be restored later.
        mov cx, 0x000B                  ; Initiate the counter with the number 11 (required length of a FAT12 file name)
                                        ; so we can iterate through each character and compare it with the file name of
                                        ; the second stage of the bootloader.
        mov si, imageName               ; Point the source for the compare operation to string that defines the file name
                                        ; of the second stage bootloader.
        push di                         ; Save the starting location of the current entry that is being compared, so we
                                        ; scan recover it if the compare operation
                                        ; found a match. This is needed because the compare operation will increment and
                                        ; thus alter the index each iteration.
        rep cmpsb                       ; Repeat the string compare as long as the characters are the same or if the cx
                                        ; is at 0 which means the file is found.
        pop di                          ; Fetch the starting address of the entry just checked from the stack.
        je loadFAT                      ; Check if the last character compare operation has set the zero flag, if so we
                                        ; found the second stage file. Remember that 0 means that there is an difference
                                        ; of 0 bits between comparing the characters.(cmpsb just subtracts di from si).
        pop cx                          ; Fetch the entry counter from the stack.
        add di, 0x0020                  ; Add 32 bits to the destination pointer so it points to the next entry in the
                                        ; root directory.
        loop .loopFilename              ; Go to the next entry to check if it contains the sesond stage bootloader.
                                        ; remember that this also decrements cx, so it knows what entry is being read.
        jmp failure                     ; Unfortunately the second bootloader was not found so notify the user.

;________________________________________________________________________________________________________________________/ § loadFAT
;   Description:
;   This function will load the file allocation table into memory.
;
loadFAT:
    ; Firstly save the starting cluster of the boot image.
    mov dx, word[di+0x001A]         ; Get the value of the 26th bit of the entry. This contains the first cluster of the FAT.
    mov word[cluster], dx           ; Get the files first cluster.

    ; Then compute the size of the FAT and store it in CX
    xor ax, ax                      ; Zero the ax register.
    mov al, byte[bpbNumberOfFATs]   ; Get the number of file allocation tables on the device.
    mul word[bpbSectorsPerFAT]      ; Then multiply them with the amount of sectors of each fat.
    mov cx, ax                      ; Save the answer to cx

    ; And calculate the location of the FAT.
    mov ax, word[bpbReservedSectors]; Adjust the location by adding the boot sector.

    ; Read the FAT into memory at address 7c00:0200
    mov bx, FAT_OFFSET                  ; Set the location to write the fat to.
    call readSectors                    ; Copy the file allocation table above the boot code at address 7c00:0200

    mov ax, 0x0050                      ;
    mov es, ax                          ; The destination for the image
    mov bx, 0x0000                      ; The destination for the image
    push bx                             ; push the destination to the stack.

;________________________________________________________________________________________________________________________/ § loadImage
;   Description:
;   This function will load the image (containing the second stage of the bootloader) from a storage device.
;
loadImage:
    ; Reference the cluster from the file allocation table.
    mov ax, word[cluster]               ; Set the address of the cluster we are going to read.
    pop bx                              ; Get the bx from stack that contains the starting address of the image.
    call convertChsToLba                ; Convert the cluster number to LBA (Logical Block Addressing).
    mov cx, cx                          ; Zero the counter register.
    mov cl, byte[bpbSectorsPerCluster]  ; Set the amount of sectors the cluster has.
    call readSectors                    ; Load the sectors to bx using ax as starting address, cl as the amount to read.
    push bx                             ; Save the value of BX

    ; Load the next cluster and Determine if the cluster is odd or even.
    mov ax, word[cluster]               ; Identify the current cluster from the file allocation table.
    mov cx, ax                          ; Copy the current cluster.
    mov dx, ax                          ; Make a temporary copy to the data register so we can use it in a calculation.
    shr dx, 0x0001                      ; Divide by 2 using an logical right shift of 1
    add cx, dx                          ; Sum the values (3/2)
    mov bx, FAT_OFFSET                  ; Set the data register to the address of the file allocation table.
    add bx, cx                          ; Add the current index to the FAT base address.
    mov dx, word[bx]                    ; Read 2 bytes from the file allocation table.
    test ax, 0x0001                     ; Test the bit pattern 0001 on the cluster.
    jnz .oddCluster                     ; If the bit pattern didn't match its a odd cluster, jump to the routine that handles them.

    ; If the cluster is even, then take the 12 low bits.
    .evenCluster:
        and dx, 0000111111111111b       ; Its an even cluster so take the lower 12 bits.
        jmp .done                       ; And jump over the odd cluster routine.

    ; If the cluster is odd, then take the high 12 bits.
    .oddCluster:
        shr dx, 0x0004                  ; It is an odd cluster so take the higher 12 bits.

    ; Then check if the sizes are correct.
    .done:
        mov word[cluster], dx           ;
        cmp dx, 0x0ff0                  ; Compare the data register to 4080
        jb loadImage                    ; Move to the next

;________________________________________________________________________________________________________________________/ § executeNextStage
;   Description:
;   This function will set the the addresses of the second stage on to the stack and move the instruction
;   pointer to that location, so the second stage gets executed.
;
executeNextStage:
    push word 0x0050                    ; Push the addess to jump to on the stack. 0x0050:0x0000
    push word 0x0000                    ; Push the addess to jump to on the stack. 0x0050:0x0000
    retf                                ; Call the return from caller function to jump the next stage.

;________________________________________________________________________________________________________________________/ § failure
;   Description:
;   The name is pretty explanatory, it is a description of me, my life, the architects of x86, Alan Tuning...
;   (｡◕‿◕｡)⊃━☆ﾟ.*･｡ﾟ Happy debugging ԅ(≖‿≖ԅ)
;
failure:
    mov si, msgFailure
    call printString
    xor ah,ah; not again!               ; Set 0 to the ax high byte as function.
    int BIOS_INT_KEYBOARD               ; Execute an BIOS interrupt that:
    int BIOS_INT_W_REBOOT               ; Reset the system. (Warm reboot)

;________________________________________________________________________________________________________________________/ ϝ printString
;   Description:
;   This function can be used to print an null terminated string to the screen using the BIOS Video service
;   interrupts.To use this function you should point the source index (SI register) to the starting address
;   of the string you want to print.
;
;   Example Call:
;   my_str: db "Hello world", 0
;   mov     si, my_str
;   call    print_string
;
printString:
    pusha   ; Save the current registers states of the CPU before altering them in this function.

    .print_character:
        ; Load Data segment Byte
        lodsb                           ; Load byte from string addressed by DS:SI to the ax low register. The Direction Flag is clear so SI
                                        ; (source index) is incremented so we can get the next character if we need to print more characters.
        or al, al                       ; Do fast logical OR on the low byte of the accumulator low byte (containing an char of the string)
        jz .return                      ; Done printing, the if the loaded byte contains an zero the or will set the zero flag.

        mov ah, ASCII_CRTL_SO           ; Set the ASCII SO (shift out) character to the high byte of the accumulator.
        int BIOS_INT_VIDEO              ; Fire an BIOS interrupt 16 (video services) that uses ax as its input, the high part of the
                                        ; accumulator register contains an ASCII SO character this will determine the video function to
                                        ; perform. The low byte contains the argument of that function (a character), so combined it will
                                        ; shift out(ah) the character stored in al.
        jmp .print_character            ; Finished printing this character move to the next.

    .return:
        popa                            ; Restore the state of the CPU registers to before executing this function.
        ret                             ; The string is printed and the registers are restored so go back to the caller.

;________________________________________________________________________________________________________________________/ ϝ readSectors
;   Description:
;   This function reads a series of sectors from a storage device to memory. It uses the cs, ax registers as arguments,
;   CX defines the amount of sectors it should read and AX defines the starting sector of the sector. ES:BX is used as
;   buffer that the read sectors should be written to.
;
readSectors:
    .main:
        mov di, 0x0005                  ; The amount of retries if an error occurs.
    .readAnSector:
        push ax                         ; Save ax, that contains the starting address of the sectors to read.
        push bx                         ; Save bx, that contains the address to copy the read sectors to.
        push cx                         ; Save cx, that contains the amount of sectors it should read.
        call convertLbaToChs            ; Get the correct register addresses.
        mov ah, 0x02
        mov al, 0x01
        mov ch, BYTE [absoluteTrack]    ; track
        mov cl, BYTE [absoluteSector]   ; sector
        mov dh, BYTE [absoluteHead]     ; head
        mov dl, BYTE [bsDriveNumber]    ; drive
        int BIOS_INT_DISK               ; invoke BIOS
        jnc .readedSuccessfull          ; test for read error
        xor ax, ax                      ; BIOS reset disk
        int BIOS_INT_DISK               ; invoke BIOS
        dec di                          ; decrement error counter
        pop cx                          ; Restore the state of the cx register.
        pop bx                          ; Restore the state of the bx register.
        pop ax                          ; Restore the state of the ax register.
        jnz .readAnSector               ; attempt to read again
        int BIOS_INT_REBOOT             ; Reset and try again.

    .readedSuccessfull:
        pop cx                          ; Restore the state of the cx register.
        pop bx                          ; Restore the state of the bx register.
        pop ax                          ; Restore the state of the ax register.
        add bx, word[bpbBytesPerSector] ; Queue the next buffer
        inc ax                          ; Increment the read counter
        loop .main                      ; Move ahead to the next sector to read.
        ret                             ; return

;________________________________________________________________________________________________________________________/ ϝ readSectors
;   Description:
;   This function is responsible for converting CHS(Cylinder/Head/Sector) addressing to LBA (Logical Block Addressing)
;   using the formula LBA = (cluster -2) * sectorPerCluster.
;
;   Function Arguments:
;   ax      Is used to pass the cluster number.
;
convertChsToLba:
    sub ax, 0x0002                      ; Cluster number - 2
    xor cx, cx                          ; Clear the counter
    mov cl, byte[bpbSectorsPerCluster]  ; Get the amount of sectors in a cluster.
    mul cx                              ; Multiply the cluster number minus 2 by the amount of sectors.
    add ax, word[datasector]            ; And add the data sector offset to it.
    ret

;________________________________________________________________________________________________________________________/ ϝ convertLbaToChs
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
convertLbaToChs:
    xor dx, dx                          ; Clear dx
    div word[bpbSectorsPerTrack]        ; Divide LBA by sectorPerTrack (the remainder is stored in dx).
    inc dl                              ; Add 1 to the modulus of LBA
    mov byte[absoluteSector],dl         ; Save the calculated absolute sector address
    xor dx, dx                          ; Clear the value.
    div word[bpbHeadsPerCylinder]       ; Divide LBA by the number number of heads. (dx has the remainder)
    mov byte[absoluteHead],dl           ; Store the absolute head.
    mov byte[absoluteTrack],al          ; Store the absolute track.
    ret

;________________________________________________________________________________________________________________________/ § Variables
;
; CHS (Cylinder, Head, Sector) Addressing variables, they store the current locations on the floppy drive.
absoluteSector  db 0x00                 ; The current sector its on the disk.
absoluteHead    db 0x00                 ; The current head of the floppy drive.
absoluteTrack   db 0x00                 ; The current track its on the floppy drives disk.

; LBA (Logic Block Addressing) variables, they store the current locations using LBA.
datasector      dw 0x0000               ; The current datasector.
cluster         dw 0x0000               ; The current cluster.

; Messages and file names.
;imageName      db "STAGE2  BIN"        ; The name of the second stage bootloader located on the FAT disk.
;imageName       db "BTLOAD1 BIN"         ; The name of the second stage bootloader located on the FAT disk.
imageName       db BOOTLOADER1_FILENAME         ; The name of the second stage bootloader located on the FAT disk.
msgLoading      db "Loading stage2...", NEWLN
msgFailure      db "Error: press any key to destroy your computer.", NEWLN

times 510-($-$$) db 0	; Pad remainder of boot sector with zeros
dw 0x0AA55		; Bootable flag constant. If this constant is present at address 512 the bios marks the the sector as bootable
