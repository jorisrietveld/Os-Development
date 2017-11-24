target remote localhost:1234
set architecture i8086
add-symbol-file bootloader.asm
display /i ($cs*16)+$pc
stepi