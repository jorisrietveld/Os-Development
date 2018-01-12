#!/usr/bin/env bash
nasm -d DEBUG -f bin first_stage.asm -o stage1.bin
echo "size of the first stage bootloader is" `stat -c "%s" stage1.bin`
hexdump stage1.bin

nasm -d DEBUG -f bin second_stage.asm -o STAGE2.SYS
echo "size of the second stage bootloader is" `stat -c "%s" STAGE2.SYS`
hexdump STAGE2.SYS

cat stage1.bin STAGE2.SYS >> boot.img
echo "size of the second stage bootloader is" `stat -c "%s" boot.img`
hexdump boot.img

qemu-system-i386 -net none -drive file=boot.img,index=0,media=disk,format=raw
