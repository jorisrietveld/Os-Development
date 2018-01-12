#!/usr/bin/env bash

# Translate the assembler code into machine code.
nasm -f bin bootloader.asm -o bootloader.bin

# Print an raw dump of the generated machine code.
hexdump bootloader.bin