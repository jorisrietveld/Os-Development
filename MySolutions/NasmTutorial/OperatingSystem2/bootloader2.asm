;
;   Author: Joris Rietveld <jorisrietveld@gmail.com>
;   Created: 13-11-2017 21:40
;   Licence: GPLv3 - General Public Licence version 3
;
;   Description:
;
;
;
;    CS (Code Segment) - Stores base segment address for code
;    DS (Data Segment) - Stores base segment address for data
;    ES (Extra Segment) - Stores base segment address for anything
;    SS (Stack Segment) - Stores base segment address for the stack
;

bits	16							; We are still in 16 bit Real Mode
org		0x7c00						; We are loaded by BIOS at 0x7C00

start:
    jmp loader			            ; jump over OEM block

;
;	OEM Parameter block (DDT Data Description Table)
;
bpbOEM:                 db "Stendex "   ; This member must be exactly 8 bytes so it aligns correctly, and it contains the name of the oem
bpbBytesPerSector:  	DW 512          ; The number of bytes in each sector.
bpbSectorsPerCluster: 	DB 1            ; The number of sectors in each cluster.
bpbReservedSectors: 	DW 1            ; The number of reserved sectors (the boot sector is not part of the file system so there is 1)
bpbNumberOfFATs: 	    DB 2            ; The number of FAT (File Allocation Tables) on the disk (FAT12 has a standard of 2 tables)
bpbRootEntries: 	    DW 224          ; The maximum amount of directories inside the root directory (floppy disks have an standard limit of 224 files)
bpbTotalSectors: 	    DW 2880         ; The total amount of sectors on the floppy disk.
bpbMedia: 	            DB 0xF0         ; Remember hexdecimal: 0xF0  equals 1111 0000 in binary and
                                        ; bit number: 7 6 5 4 3 2 1 0
                                        ; bit value:  1 1 1 1 0 0 0 0
                                        ; The media table contains settings about the properties of the disk, this are the options:
                                        ; Bit 0: Sides/Heads    = 0 if it is single sided, 1 if its double sided
                                        ; Bit 1: Size           = 0 if it has 9 sectors per FAT, 1 if it has 8.
                                        ; Bit 2: Density        = 0 if it has 80 tracks, 1 if it is 40 tracks.
                                        ; Bit 3: Type           = 0 if its a fixed disk (Such as hard drive), 1 if removable (Such as floppy drive)
                                        ; Bits 4 to 7 are unused, and always 1.

bpbSectorsPerFAT: 	    DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors: 	    DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	            DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0x42424242   ; The meaning of life, the universe and everything...
                                        ;Would you have thought writing a bootloader would be so philosophical.

bsVolumeLabel: 	        DB "MOS FLOPPY "; The name of the image
bsFileSystem: 	        DB "FAT12   "   ; The file system of the image (use FAT 12 because of size limitations and simplicity)

;
; Constants.
;
MESSAGE:	db "Welcome to stendex OS", 0   ; An string constant with an message and termination character.

;
; The print function
;
; Definitions:
; ASCII =   American Standard Code for Information Interchange
; BIOS  =   Basic Input Output System
; Al    =   Accumulator low byte
; Ah    =   Accumulator high byte
; ax    =   Accumulator register ( high + low, so 2 bytes = 16 bits)
; bl    =   Base low byte
; bh    =   Base high byte
; bx    =   Base register, Used as a pointer to data (located in segment register DS, when in segmented mode).
;
; Documentation:
; The print function uses an BIOS interrupt and a ASCII control code (in ah) with an ASCII character code (in al) to print
; an character to the screen.
;
; In this function:
; INT 0x10 - VIDEO TELETYPE OUTPUT, get the value of ax and al and output it.
; ah = 0x0E, this is an ASCII control code: Shift Out (SO).
; al = Character to write, can be every ASCII character you want to print.
; bh - Page Number (Should be 0)
; bl = Foreground color (Graphics Modes Only)
;
print:
	lodsb           ; Load next byte from string in SI (Segment Index) to AL

	or al, al       ; Does AL or AL = 0, are we at the termination character?
	jz printDone    ; Yes, so we found the termination character (an 0) at the end of the string, stop printing and return.
	                ; JZ = Jump if the zero flag is set in the CPU register (this happens when the output of an operation is zero, like 0 or 0 = set zero flag)

	mov ah, 0x0E    ; Nope, set the high byte of the accumulator to the function we want to execute. Which is printing hex: 0E
	int 0x10        ; Fire an BIOS interrupt for VGA, this will take the ah (containing print function) and al (containing the character)
	                ; as argument (combined register of al + ah = ax) as argument. so the character gets printed on the screen.
	jmp print       ; Jump to the print label so we can fetch and print the next character from the string.

    printDone:      ; print::printDone this label points the the return of the print function.
        ret         ; Return to the previous function.

;
; Bootloader Entry Point
;

; Setup segments to insure they are 0. Remember that
	mov	ds, ax		; we have ORG 0x7c00. This means all addresses are based
	mov	es, ax		; from 0x7c00:0. Because the data segments are within the same
				; code segment, null em.
loader:
	xor ax, ax ; Use an xor to fill the ax with zeros, this is faster than creating an value and copying it to the register. ( 1 xor 1 = 0)

	mov ds, ax ; Setup the data segments to ensure they are starting at 0 using the value from ax, because we have an org 0x7c00 at the top
	mov ds, ax ; the actual address 0x7c00:0 (offset:index)
	mov si, MESSAGE ; Copy the message into the segment index so it can be used as argument in the print function.
	call print      ; Call the print function that will load the data and print each character.

	cli			; Clear all Interrupts
	hlt			; halt the system

;
; Reset the bootloader ( go to the fist byte of the floppy image)
;
.reset:
    mov ab, 0
    mov dl, 0
    int 0x13
    jc .reset       ; Jump if the carry flag is set ( there was an error reset again )
    mov ax, 0x1000
    mov es, ax      ;
    xor bx, bx

;
; Read the next sector from the floppy drive.
;
.readDisk:
    mov ah, 0x02
    mov al, 1
    mov ch, 1   ; read next sector on the same track
    mov cl, 2   ; Read sector (2 because the first sector is already in use.)
    mov dh, 0   ; Read from the first head
    mov dl, 0   ; Read from the first drive (drive 0 is the floppy drive)
    int 0x13    ; Fire 0x13 BIOS interrupt, this interrupt is called read sector and uses the arguments above to read an sector.
    jc .readDisk



times 510 - ($-$$) db 0		; We have to be 512 bytes. Clear the rest of the bytes with 0

dw 0xAA55			; Boot Signiture