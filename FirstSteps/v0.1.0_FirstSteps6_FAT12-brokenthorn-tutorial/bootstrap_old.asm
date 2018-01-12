;                                                                                       ,   ,           ( VERSION 0.0.1
;                                                                                         $,  $,     ,   `̅̅̅̅̅̅( 0x001
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

jmp short start_bootstrapping     ; Jump to the initiation function that loads the second loader.
nop                         ; Padding to align the bios parameter block.

;________________________________________________________________________________________________________________________/ § BIOS Parameter Block
;   Description:                                                                                                           ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅
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
bsSerialNumber 	        dd 00000000h    ; This gets overwritten every time the image get written.
bsVolumeLabel  	        db "JORIX OS   "; The label of the volume.
bsFileSystem  	        db "FAT12   "   ; The type of file system.

start_bootstrapping:
    mov ax, 0x07c0                  ; This is for calculating where to put the stack. Set it 4k above the buffer.
    add ax, 544                     ; Add the buffer to it
    cli                             ; Disable the global interrupts to prevent tipple faults on hardware interrupts.
    mov ss, ax                      ; Adjust the stack segment.
    mov sp, 4096                    ; Set the top of the stack at the calculated address.
    sti                             ; Re enable the hardware interrupts.
    mov ax, 0x07c0                  ; The address for the data sector.
    mov ds, ax                      ; Set the data segment to the the address.
    cmp dl, 0                       ; Check if the BIOS correctly initiated the data sector.
    je no_fix_needed                ; If everything is is fine jump over the fix below.
    mov [bsDriveNumber], dl         ; Save the actual location to the bios parameter block.
    mov ah, 0x08                    ; Set the Read Drive Parameters byte that will be used with int 13 (drive services).
    int 0x13                        ; Execute an low level disk service interrupt.
    jc fatal_disk_error             ; The disk service will set the carry flag on error, check it here.
    and cx, 0x3f                    ; Do an logic and operation with the maximum sector count.
    mov [bpbSectorsPerTrack], cx    ; Update the sectors per track.
    movzx dx, dh                    ; Move the high byte suffixed with zero's to the same register.
    add dx, 1                       ; Add 1 for the total.
    mov [bpbHeadsPerCylinder], dx   ; Save to the amount of heads each cylinder has.

no_fix_needed:
    mov eax, 0                      ; For old BIOS'es

floppy_of:
    mov ax, 19
    call lba_to_hts
    mov si, buffer
    mov bx, ds
    mov es, bx
    mov bx, si
    mov ah, 2
    mov al, 14
    pusha       ; Prepare to enter the loop, make sure we can recover the register states.

read_root_dir:
    popa    ;
    pusha

    stc ; Set the carry flag.
    int 0x13

    jnc search_root_dir ; If the read was successful (this should have cleared the carry flag)  jump ahead.
    call reset_floppy   ;
    jnc read_root_dir   ; Did the reset floppy work, then make an other attempt.
    jmp reboot          ; Otherwise give up and restart the system.

search_root_dir:
    popa
    mov ax, ds
    mov es, ax
    mov di, buffer
    mov cx, word[bpbRootEntries]
    mov ax, 0

next_root_dir_entry:
    xchg cx, dx
    mov si, stage2_file_name
    mov cx, 0x000B              ; Set the counter to 11 (the standard FAT length of an file name)
    rep cmpsb                   ; Repeat an character compare until the counter is 0.
    je found_stage2             ;

    add ax, 0x0020              ; add 32 to ax for the next fat entry.
    mov di, buffer              ;
    add di, ax                  ;

    xchg dx, cx                 ; Get the outer counter back that we stored in the data register.
    loop next_root_dir_entry    ; Check the next boot entry.

    mov si, file_not_found      ; Stage 2 is not found.
    call print_string           ; todo REMOVE THIS WITH MY FANCY PRINT MACROS
    jmp reboot                  ; Notify the user that we are unable to boot and reboot the system.

found_stage2:
    mov ax, word [es:di+0x0f]   ; Add the offset + 15 for the first cluster.
    mov word[cluster], ax       ; Set the cluster to the calculated value.
    mov ax, 1
    call lba_to_hts

    mov di, buffer              ;
    mov bx, di                  ;
    mov ah, 0x02                ; Set low level disk function to read sectors.
    mov al, [bpbSectorsPerFAT]  ; Set the amount of sectors to read to the amount of sectors each fat has.
    pusha

read_file_alloc_table:
	popa                        ; Restore the registers in case they are altered by int 0x13
	pusha
	stc                         ; Set the carry flag
	int 0x13                    ; Read sectors using the BIOS

	jnc read_fat_ok			    ; If read went OK, skip ahead
	call reset_floppy		    ; Otherwise, reset floppy controller and try again
	jnc read_file_alloc_table   ; Floppy reset OK?

fatal_disk_error:
	mov si, disk_error          ; There was an fatal error load the message.
	call print_string           ; Notify the user of the error.
	jmp reboot                  ; Reboot the system.

read_fat_ok:
    popa                        ; Save the current state CPU registers.
    mov ax, 0x2000              ;Set the address of the sector where the second stage will be loaded.
    mov es, ax                  ; Set the extra segment to this location.
    mov bx, 0x0000              ; Set the base register to 0
    mov ah, 0x02                ; Set the function for the low lever disk services to floppy read.
    mov al, 1                   ; Set the drive number.
    push ax	                    ; Save in case we (or int calls) lose it

load_file_sector:
    mov ax, word [cluster]      ; Convert sector to logical block addressing (LBA)
    add ax, 0x001F              ;
    call lba_to_hts             ; Call the convert function so we can use 0x13 to load.

    mov ax, 0x2000              ; The address past the bytes that are already leaded.
    mov es, ax                  ; Set the segment to start past the loaded bytes.
    mov bx, word [pointer]      ; Set the base to the contents of the pointer.
    pop ax                      ; Get the address from the stack.
    push ax                     ; And save it again to the stack to ensure we don't lose it.
    stc                         ; Set the carry flag.
    int 0x13                    ; Execute the low level disk service interrupt to load the sectors.
    jnc calculate_next_cluster	; If the carry flag is clear (so there are no errors).

    call reset_floppy		    ; The carry flag was set by because of an read error, reset the config.
    jmp load_file_sector        ; Try loading the sectors for the file again.

calculate_next_cluster:
    mov ax, [cluster]
    mov dx, 0x0000              ; Set the data register to 0.
    mov bx, 0x03                ; Set the base register to 3.
    mul bx                      ; Multiply the cluster by 3
    mov bx, 2                   ; Multiply the cluster by 2
    div bx                      ; DX = [cluster] mod 2
    mov si, buffer
    add si, ax			        ; AX = word in FAT for the 12 bit entry
    mov ax, word [ds:si]
	or dx, dx                   ; If DX = 0 [cluster] is even; if DX = 1 then it's odd
	jz even	                    ; If [cluster] is even, drop last 4 bits of word
                                ; with next cluster; if odd, drop first 4 bits
odd:
	shr ax, 4                   ; Shift out first 4 bits (they belong to another entry)
	jmp short next_cluster_cont
even:
	and ax, 0x0FFF              ; Mask out final 4 bits

next_cluster_cont:
	mov word [cluster], ax		; Store cluster
	cmp ax, 0x0FF8              ; FF8h = end of file marker in FAT12
	jae end
	add word [pointer], 512		; Increase buffer pointer 1 sector length
	jmp load_file_sector

end:                            ; We've got the file to load!
	pop ax                      ; Clean up the stack (AX was pushed earlier)
	mov dl, byte [bootdev]      ; Provide kernel with boot device info
	jmp 0x2000:0x0000           ; Jump to entry point of loaded kernel!

reboot:
	mov ax, 0x00                ; Set the function for the input services to read keys.
	int 0x16                    ; Wait for keystroke.
	mov ax, 0                   ; Set the function to 0x0000 for an system reboot.
	int 19h                     ; Execute the interrupt to reboot the system.

reset_floppy:		; IN: [bootdev] = boot device; OUT: carry set on error
	push ax
	push dx
	mov ax, 0
	mov dl, byte [bootdev]
	stc
	int 13h
	pop dx
	pop ax
	ret

; Calculate head, track and sector settings for int 13h
lba_to_hts:         ; IN: logical sector in AX, OUT: correct registers for int 13h
	push bx
	push ax
	mov bx, ax      ; Save logical sector

	mov dx, 0  ; First the sector
	div word [bpbSectorsPerTrack]
	add dl, 0x01     ; Physical sectors start at 1
	mov cl, dl      ; Sectors belong in CL for int 13h
	mov ax, bx
	mov dx, 0       ; Now calculate the head
	div word [bpbSectorsPerTrack]
	mov dx, 0
	div word [bpbHeadsPerCylinder]
	mov dh, dl      ; Head/side
	mov ch, al      ; Track
	pop ax
	pop bx
	mov dl, byte [bootdev]  ; Set correct device
	ret
print_string:
    pusha   ; Save the current registers states of the CPU before altering them in this function.

    .print_character:
        ; Load Data segment Byte
        lodsb       ; Load byte from string addressed by DS:SI to the ax low register. The Direction Flag is clear so SI
                    ; (source index) is incremented so we can get the next character if we need to print more characters.
        or al, al   ; Do fast logical OR on the low byte of the accumulator low byte (containing an char of the string)
        jz .return  ; Done printing, the if the loaded byte contains an zero the or will set the zero flag.

        mov ah, 0x0e; Set the ASCII SO (shift out) character to the high byte of the accumulator.
        int 0x10    ; Fire an BIOS interrupt 16 (video services) that uses ax as its input, the high part of the
                    ; accumulator register contains an ASCII SO character this will determine the video function to
                    ; perform. The low byte contains the argument of that function (a character), so combined it will
                    ; shift out(ah) the character stored in al.
        jmp .print_character ; Finished printing this character move to the next.

    .return:
        popa    ; Restore the state of the CPU registers to before executing this function.
        ret     ; The string is printed and the registers are restored so go back to the caller.


stage2_file_name db "STAGE2  BIN"
disk_error	     db "Floppy error! Press any key...", 0
file_not_found	 db "STAGE2.BIN not found!", 0

bootdev	db 0 	; Boot device number
cluster	dw 0 	; Cluster of the file we want to load
pointer	dw 0 	; Pointer into Buffer, for loading kernel

times 510-($-$$) db 0	; Pad remainder of boot sector with zeros
dw 0x0AA55		; Bootable flag constant. If this constant is present at address 512 the bios marks the the sector as bootable.

buffer:


