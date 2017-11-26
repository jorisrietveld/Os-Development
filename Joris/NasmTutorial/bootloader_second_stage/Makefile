UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	STAT := gstat
else
	STAT := stat
endif

all: first_stage.img

first_stage.img: first_stage.asm Makefile
	nasm -d DEBUG -f bin first_stage.asm -o first_stage.img
	@echo "size is" `$(STAT) -c "%s" first_stage.img`
	nasm -f bin first_stage.asm -o first_stage.img

run: first_stage.img
	@qemu-system-i386 -net none -drive file=first_stage.img,index=0,media=disk,format=raw

debug: first_stage.img
	@qemu-system-i386 -net none -s -S -boot a -drive file=first_stage.img,index=0,media=disk,format=raw & gdb -q

clean:
	rm -f bootloader.img