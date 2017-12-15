#!/usr/bin/env bash

# Translate the assembler code into machine code.
nasm -f bin bootloader.asm -o bootloader.bin

# Print an raw dump of the generated machine code.
hexdump bootloader.bin

# run the created bootloader
qemu-system-x86_64 -fda bootloader.bin -boot a -no-fd-bootchk