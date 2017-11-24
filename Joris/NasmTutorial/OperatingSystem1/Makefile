UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	STAT := gstat
else
	STAT := stat
endif

all: bootloader.img

bootloader.img: bootloader.asm Makefile
	nasm -d DEBUG -f bin bootloader.asm -o bootloader.img
	@echo "size is" `$(STAT) -c "%s" bootloader.img`
	nasm -f bin bootloader.asm -o bootloader.img

run: bootloader.img
	@qemu-system-i386 -s -S -drive file=bootloader.img,index=0,media=disk,format=raw

clean:
	rm -f bootloader.img
