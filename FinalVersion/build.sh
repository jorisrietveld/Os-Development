#!/bin/sh
#________________________________________________________________________________________________________________________/ Options
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
IMAGE_NAME=JorixOS              # The name of the disk images.
USER_UNPRIVILEGED=joris:joris   # The name of the non root user to alter the privileges on the created files.
DISK_IMG_DIR=disk_images/       # The directory containing the output

# You probably don't want to chance this.
BOOTSTRAP_NAME=bootstrap        # The 512 byte bootstrap loader.
STAGE2_NAME=stage2              # The kernel loader.

#________________________________________________________________________________________________________________________/ Helper print functions
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
notify_error(){
    echo "\e[91m ✗ $1\e[39m"
    exit
}
notify(){
    echo "\e[49m ► $1\e[39m"
}
notify_success(){
    echo "\e[92m ✓ $1\e[39m"
}

print_fancy(){
    if which toilet >/dev/null ; then
        toilet -t -F gay:border -f $1 $2
    else
        echo $2
    fi
}
#________________________________________________________________________________________________________________________/ Check root
#   Check if the executing user is root, this is needed to mount the loop-back device for creating the floppy image.
#
# Test if the user has root privileges, this is needed for creating the disk image.
if test "`whoami`" != "root" ; then
    print_fancy smmono12 "You shall not pass!"
	#toilet -t -f smmono12 -F gay:border You shall not pass!
	notify_error "You have to have root privileges for building the operating system."
	print_fancy pagga "Try again with god mode enabled."
	#toilet -t -W -f pagga -F gay:border "Try again with god mode enabled"
	exit
else
    print_fancy mono12 "Jorix OS"
    #toilet -t -W  -f mono12 -F gay:border "Jorix OS"
    #toilet -t -f pagga -F gay:border "Building System"
fi

#________________________________________________________________________________________________________________________/ Make empty Floppy image
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
if [ ! -e ${DISK_IMG_DIR}${IMAGE_NAME}.flp ]
then
	notify "> Creating new floppy image..."
	mkdosfs -C ${DISK_IMG_DIR}${IMAGE_NAME}.flp 1440 || exit
	chown ${USER_UNPRIVILEGED} ${DISK_IMG_DIR}${IMAGE_NAME}.flp
	chmod 777 ${DISK_IMG_DIR}${IMAGE_NAME}.flp
	notify_success "successfully created the floppy image: ${DISK_IMG_DIR}${IMAGE_NAME}.flp\n"
fi

#________________________________________________________________________________________________________________________/ Compile assembly files.
#   Use NASM to assemble the first and second stage of bootloader to an raw binary.
#   This loader is only responsible for loading the second stage from the disk and defining the file system.
#
notify "Compiling all assembly files..."
notify "Assembling the first stage of the bootloader..."
cd ./src/boot/
nasm -O0 -w+orphan-labels -f bin -o ${BOOTSTRAP_NAME}.bin ${BOOTSTRAP_NAME}.asm || exit
chown ${USER_UNPRIVILEGED} ${BOOTSTRAP_NAME}.bin
chmod 777 ${BOOTSTRAP_NAME}.bin
notify_success "successfully assembled the first stage of the bootloader to an binary: ${BOOTSTRAP_NAME}.bin"

notify "Assembling the second stage of the bootloader..."
nasm -O0 -w+orphan-labels -f bin -o ${STAGE2_NAME}.bin ${STAGE2_NAME}.asm || exit
chown ${USER_UNPRIVILEGED} ${STAGE2_NAME}.bin
chmod 777 ${STAGE2_NAME}.bin
notify_success "successfully assembled the second stage of the bootloader to an binary: ${STAGE2_NAME}.bin"
notify_success "Done assembling files.\n"
cd ../../

#________________________________________________________________________________________________________________________/ Install bootloader
#   Copy the first stage of the bootloader to the floppy image.
#
notify "Adding bootloader to floppy image..."
dd status=noxfer conv=notrunc if=src/boot/${BOOTSTRAP_NAME}.bin of=${DISK_IMG_DIR}${IMAGE_NAME}.flp || exit
notify_success "Successfully copied the bootloader to the floppy image: ${DISK_IMG_DIR}${IMAGE_NAME}.flp"

#________________________________________________________________________________________________________________________/ Install stage2 & kernel
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
#
notify "Creating and mounting the floppy image as an loop-back device..."
rm -rf /tmp/tmp-floppy-loop || exit
mkdir /tmp/tmp-floppy-loop && mount -o loop -t vfat ${DISK_IMG_DIR}${IMAGE_NAME}.flp /tmp/tmp-floppy-loop || exit
notify_success "Successfully mounted the floppy to /tmp/tmp-floppy-loop"

notify "Coping the second stage loader, kernel and programs on to the virtual floppy..."
cp "src/boot/${STAGE2_NAME}.bin" /tmp/tmp-floppy-loop || exit
notify_success "Successfully copied the second stage loader /tmp/tmp-floppy-loop"
sleep 0.2

notify "All files are copied, unmounting /tmp/tmp-floppy-loop..."
umount /tmp/tmp-floppy-loop || exit

notify "Removing the temporary directory: /tmp/tmp-floppy-loop..."
rm -rf /tmp/tmp-floppy-loop || exit
notify_success "Done.\n"

#________________________________________________________________________________________________________________________/ Create CD-DISK ISO
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
#
notify "Creating CD ISO image..."
rm -f ${DISK_IMG_DIR}${IMAGE_NAME}.iso
genisoimage -quiet -V 'JORIXOS' -input-charset iso8859-1 -o ${DISK_IMG_DIR}${IMAGE_NAME}.iso -b ${IMAGE_NAME}.flp ${DISK_IMG_DIR} || exit
chown ${USER_UNPRIVILEGED} disk_images/${IMAGE_NAME}.iso
chmod 777 ${DISK_IMG_DIR}${IMAGE_NAME}.iso
notify_success "Successfully created an CD-ROM image: ${DISK_IMG_DIR}${IMAGE_NAME}.iso"

print_fancy pagga "Done building!"

#________________________________________________________________________________________________________________________/ Start the OS ?
#   If the user wants it, boot the os with qemu
#
notify "Do you want to start Jorix os? [Y/n]"
read  answer
if echo "$answer" | grep -iq "^y" ;then
    qemu-system-i386 -net none -fda ${DISK_IMG_DIR}${IMAGE_NAME}.flp -boot a
else
    notify_success "Okey, you can also run it with run.sh"
fi

