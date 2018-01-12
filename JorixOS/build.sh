#!/bin/sh
PROJECT_ROOT="`pwd`" # DANGEROUS, USED WITH: rm -rf and dd, IF SET WRONG LIKE AN / WITH SPACE WILL ALL YOUR DATA
#________________________________________________________________________________________________________________________/ Options
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.

 # The name of the disk images.
IMAGE_NAME=JorixOS

# The name of the non root user to alter the privileges on the created files.
USER_UNPRIVILEGED=joris

# The directory containing bootable disk images.
DISK_IMG_DIR="disk_images/"

# If set to 1, it removes all compiler output except the images, 0 to leave them after building.
CLEAN_AFTER_BUILD=0

# You probably don't want to chance this.
BOOTSTRAP_NAME=bootstrap    # The 512 byte bootstrap loader.
STAGE2_NAME=stage2          # The kernel loader.
OUTPUT_PRIVILEGE_LEVEL=777  # File privileges on compiled binaries.
OUTPUT_DIRECTORY="out/"     # Directory for the compiled binaries. Ignored when either CLEAN_AFTER_BUILD or OUTPUT_IN_SOURCE_DIR is set to 1.
OUTPUT_IN_SOURCE_DIR=1      # Place the compiled binaries in the same directory as the source 1, use OUTPUT_DIR = 0
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
USER="$USER_UNPRIVILEGED"
#________________________________________________________________________________________________________________________/ Check root
#   Check if the executing user is root, this is needed to mount the loop-back device for creating the floppy image.
# Test if the user has root privileges, this is needed for creating the disk image.
if test "`whoami`" != "root" ; then
    print_fancy smmono12 "You shall not pass!"
	notify_error "You have to have root privileges for building the operating system."
	print_fancy pagga "Try again with god mode enabled."
	exit
else
    print_fancy mono12 "Jorix OS"
fi

#________________________________________________________________________________________________________________________/ Make empty Floppy image
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
if [ ! -e ${DISK_IMG_DIR}${IMAGE_NAME}.flp ]
then
    notify "> Creating new floppy image..."
    FLP_OUT="${PROJECT_ROOT}/${DISK_IMG_DIR}/${IMAGE_NAME}.flp"   # The absolute path + floppy_image.flp to be created.

	sudo -u "${USER}" mkdosfs -C ${FLP_OUT} 1440 && chmod 777 ${FLP_OUT} || exit  # Create an floppy image of 1.44 MB
	notify_success "successfully created the floppy image: ${DISK_IMG_DIR}${IMAGE_NAME}.flp\n"
fi

#________________________________________________________________________________________________________________________/ Compile assembly files.
#   Use NASM to assemble the first and second stage of bootloader to an raw binary.
#   This loader is only responsible for loading the second stage from the disk and defining the file system.
#
notify "Compiling all assembly files..."
notify "Assembling the first stage of the bootloader..."
cd ./src/boot/ || exit

BOOT_OUT="${BOOTSTRAP_NAME}.bin"
STG2_OUT="${STAGE2_NAME}.bin"

sudo -u "${USER}" rm -rf ${BOOT_OUT} ${STG2_OUT} # First clean old binaries.

sudo -u "${USER}" nasm -O0 -w+orphan-labels -f bin -o ${BOOT_OUT} ${BOOTSTRAP_NAME}.asm && chmod 777 ${BOOT_OUT} || exit
notify_success "successfully assembled the first stage of the bootloader to an binary: ${BIN_OUT}.bin" && notify "Assembling the second stage of the bootloader..."
sudo -u "${USER}" nasm -O0 -w+orphan-labels -f bin -o ${STG2_OUT} ${STAGE2_NAME}.asm && chmod 777 ${STG2_OUT} || exit

notify_success "successfully assembled the second stage of the bootloader to an binary: ${BIN_OUT}.bin"
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
    if which ponysay >/dev/null ; then
        ponysay  "Done building, do you want to start Jorix OS? [Y/n]"
    else
        echo "Done building, do you want to start Jorix OS? [Y/n]"
    fi
    # Wait for the user to decide if he want to run the build operation system.
    read  answer
    if echo "$answer" | grep -iq "^y" ;then
        BOOT_DEVICE="${DISK_IMG_DIR}${IMAGE_NAME}.flp"

       # qemu-system-i386  -net none -fda ${DISK_IMG_DIR}${IMAGE_NAME}.flp -boot a -format raw

        qemu-system-i386 -net none -boot a -drive format=raw,file=${BOOT_DEVICE},index=0,if=floppy
    else
        notify_success "Okey, you can also run it with run.sh"
    fi

