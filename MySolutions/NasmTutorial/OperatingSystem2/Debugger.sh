#!/usr/bin/env bash
# Translate the assembler code into machine code.
#nasm bootloader.asm -f bin -o os.flp -l os.lst

# Print an raw dump of the generated machine code.
#hexdump bootloader.bin

# run the created bootloader
#qemu-system-i386 -s -S -fda bootloader.bin

#$ nasm hellombr.asm -f elf -g -o hellombr.elf
#$ objcopy -O binary hellombr.elf hellombr.img
#$ qemu -s -S -fda hellombr.img -boot a
#$ gdb
#(gdb) symbol-file hellombr.elf
#(gdb) target remote localhost:1234
#nasm bootloader.asm -f elf -g -o bootloader.elf
nasm bootloader.asm -f bin -o bootloader.img
nasm bootloader.asm -f elf -g -o bootloader.elf
objcopy -O binary bootloader.elf bootloader.img
#qemu-system-i386 -s -S -fda bootloader.img -boot a
