UNAME := $(shell uname)
STAT := stat

all: stage1.img

stage1.sys: first_stage.asm Makefile
	nasm -d DEBUG -f bin first_stage.asm -o stage1.img
	nasm -d DEBUG -f bin second_stage.asm -o stage2.img
	@echo "size of the first stage bootloader is" `$(STAT) -c "%s" stage1.img`
	@echo "size of the second stage bootloader is" `$(STAT) -c "%s" stage2.img`
	#nasm -f bin first_stage.asm -o first_stage.img

run: first_stage.img
	@qemu-system-i386 -net none -drive file=stage1.img,index=0,media=disk,format=raw

dump: first_stage.img
	@echo "Hexdump of the first stage of the bootloader."
	@hexdump stage1.img
	@echo "Hexdump of the second stage of the bootloader."
	@hexdump stage2.img

debug: first_stage.img
	@qemu-system-i386 -net none -s -S -boot a -drive file=first_stage.img,index=0,media=disk,format=raw & gdb -q

clean:
	rm -f stage1.img
	rm -f stage2.img