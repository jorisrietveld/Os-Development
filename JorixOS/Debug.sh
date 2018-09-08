#!/usr/bin/env bash
#IMAGE_NAME=JorixOS
#IMAGE_FORMAT=flp
#IMAGES_LOCATION=disk_images/

gdb -x debugger.gdb
set architecture i8086
$ gdb
(gdb) target remote localhost:1234
(gdb) set architecture i8086
(gdb) break *0x7c00
(gdb) cont