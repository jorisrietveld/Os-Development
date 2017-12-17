#!/usr/bin/env bash
# Translate the assembler code into machine code.
nasm -f bin bootloader.asm -o bootloader.bin

# Print an raw dump of the generated machine code.
hexdump bootloader.bin

# run the created bootloader
qemu-system-i386 -boot a -fda bootloader.bin

# gdb -x debug3.gdb

#gdb target remote localhost:1234 set architecture i8086 display /i ($cs*16)+$pc stepi
#add-symbol-file bootloader.bin 0x7c00
#target remote | qemu -S -gdb stdio -m 16 -boot c -hda drive0.img
# step into the guest BIOS (seabios) stepi stepi stepi stepi stepi stepi stepi stepi stepi stepi br *0x7c00 # set breakpoint in the MBR cont
#$ nasm hellombr.asm -f elf -g -o hellombr.elf
#$ objcopy -O binary hellombr.elf hellombr.img
#$ qemu -s -S -fda hellombr.img -boot a
#$ gdb
#(gdb) symbol-file hellombr.elf
#(gdb) target remote localhost:1234