UNAME := $(shell uname)
STAT := stat

all: stage1.bin stage2.bin boot.img

stage1.bin: first_stage.asm Makefile
	nasm -d DEBUG -f bin first_stage.asm -o stage1.bin
	@echo "size of the first stage bootloader is" `$(STAT) -c "%s" stage1.bin`

stage2.bin: second_stage.asm Makefile
	nasm -d DEBUG -f bin second_stage.asm -o stage2.bin
	@echo "size of the second stage bootloader is" `$(STAT) -c "%s" stage2.bin`

boot.img: stage1.bin stage2.bin Makefile
	cat stage1.bin stage2.bin > boot.img
	@echo "size of the second stage bootloader is" `$(STAT) -c "%s" boot.img`

run: boot.img
	@qemu-system-i386 -net none -drive file=boot.bin,index=0,media=disk,format=raw

dump: stage1.bin stage2.bin
	@echo "Hexdump of the first stage of the bootloader."
	@hexdump stage1.bin
	@echo "Hexdump of the second stage of the bootloader."
	@hexdump stage2.bin
	@echo "Hexdump of the bootable image."
	@hexdump boot.img

debug: stage1.bin
	@qemu-system-i386 -net none -s -S -boot a -drive file=boot.img,index=0,media=disk,format=raw & gdb -q

clean:
	rm -f stage1.bin
	rm -f stage2.bin
	rm -f boot.img