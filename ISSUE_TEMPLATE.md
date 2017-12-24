### Type: _Bug/Question/Feature request/Comment_
> Description: 
This is only an example it is not required and I added it to comply with the GitHub community standards.
If you are reporting an bug please fill in the Expected behavour, Actual behavour, Platform Info and additional Info and 
a good description like:

> Example: I edited the build.sh script and wanted to cheance the temporary floppy mount directory so I cheanced the `$FD` 
variable from `$FD="/tmp/floppy-drive"`it to: 
```
$FD="/ tmp/disk-clean-up"
rm -rf $FD || exit
mkdir $FD && mount -o loop -t vfat jorix.flp $FD && cp stage2.bin kernel.bin $FD || exit
umount /tmp/tmp-floppy-loop && rm -rf $FD || exit
```

### Exprected bahavour
> Example:
 The creation of an directory in the tmp folder to mount my floppy image.

### Actual behavour
> Example:
 I got suddenly a lot of more free space on my hard disk drive, but I am having trubble finding my all my unbacked-up photos
 from tha past 10 years.

### Platform Info
> Example:
- *OS:* _Linux_
- *OS Architecture* _x86_64_
- *Nasm Version:* _2.13.02_
- *Disc utils:* _mkdosfs, dd, fdutil, genisoimage_
- *Commandline version:* _Bash 4.4.12(1)_
- *Emulator(s)* _qemu-system-i386,qemu-system-x86_64, Bochs, Virtualbox_

### Additional Info
> Example:
_Is there something else that will maybe help me to find the bug?_
_Example: While I encounted this bug that crashed the computter, I was drunk and spend a liter of beer over the CPU_
