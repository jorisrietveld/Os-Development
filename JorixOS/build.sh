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
DISK_IMG_DIR="${PROJECT_ROOT}/disk_images"

# If set to 1, it removes all compiler output except the images, 0 to leave them after building.
CLEAN_AFTER_BUILD=0

# You probably don't want to chance this.
BOOTSTRAP_NAME=bootstrap    # The 512 byte bootstrap loader.
STAGE2_NAME=stage2          # The kernel loader.
KERNEL_NAME=kernel          # The Kernel name

BOOT_OUT="${BOOTSTRAP_NAME}.bin"
STAGE2_OUT="${STAGE2_NAME}.bin"
KERNEL_OUT="KRNL.SYS"
BOOT_DIRECTORY="${PROJECT_ROOT}/src/boot"
KERNEL_DIRECTORY="${PROJECT_ROOT}/src/kernel"

OUTPUT_PRIVILEGE_LEVEL=777                          # File privileges on compiled binaries.

FLOPPY_OUT="${DISK_IMG_DIR}/${IMAGE_NAME}.flp"      # The absolute path + floppy_image.flp to be created.
CD_OUT="${DISK_IMG_DIR}/${IMAGE_NAME}.iso"          # The absolute path + floppy_image.flp to be created.
TEMP_FLOPPY_MOUNT="${PROJECT_ROOT}/loopback_flp"

#________________________________________________________________________________________________________________________/ Helper print functions
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
notify_error(){     echo "\e[91m ✗ $1\e[39m"; }

notify(){           echo "\e[49m ► $@\e[39m"; }

notify_success(){   echo "\e[92m ✓ $1\e[39m"; }

print_fancy(){
    if which toilet >/dev/null ; then
        toilet -t -F gay:border -f $1 $2
    else
        echo $2
    fi
}

fix_file_permissions(){
    NAME_OF_CREATED_FILE="$1"

    if [ -f "${NAME_OF_CREATED_FILE}" ] ; then
        chmod "${OUTPUT_PRIVILEGE_LEVEL}" "${NAME_OF_CREATED_FILE}"
        chown "${USER_UNPRIVILEGED}" "${NAME_OF_CREATED_FILE}"
    else
        notify_error "Error updating file permissions, because the file ${NAME_OF_CREATED_FILE} does not exist."
        notify_error "Files in this directory:"
        ls -l
        exit
    fi
}
# safe_remove? [filename] [type]
_safe_rm(){
    FILE_TO_REMOVE="$1"
    TYPE="$2"
    if [ ! -e "${FILE_TO_REMOVE}" ] ; then notify_error "The file ${FILE_TO_REMOVE} does not exist."
    elif [ -f "${FILE_TO_REMOVE}" ] && [ "${TYPE}" -eq 0 ] ; then echo "   - $(rm -v ${FILE_TO_REMOVE})"
    elif [ -d "${FILE_TO_REMOVE}" ] && [ "${TYPE}" -eq 1 ] ; then echo "   - $(rm -v -rf ${FILE_TO_REMOVE})"
    elif [ -e "${FILE_TO_REMOVE}" ] && [ "${TYPE}" -eq 2 ] ; then echo "   - $(rm -v -rf ${FILE_TO_REMOVE})"
    else notify_error "Error wrong type: ${TYPE} for file ${FILE_TO_REMOVE}" ; fi
}

#________________________________________________________________________________________________________________________/ Check root
#   Check if the executing user is root, this is needed to mount the loop-back device for creating the floppy image.
# Test if the user has root privileges, this is needed for creating the disk image.
if test "`whoami`" != "root" ; then
    print_fancy smmono12 "You shall not pass!"
    notify_error "You have to have root privileges for building the operating system."
	print_fancy pagga "Try again with god mode enabled." && exit
else
    print_fancy mono12 "Jorix OS"
fi

#________________________________________________________________________________________________________________________/ Make empty Floppy image
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
if [ ! -e "${FLOPPY_OUT}" ] ;   then notify "> Creating new floppy image..."
	mkdosfs -v -C "${FLOPPY_OUT}" 1440 || exit   # Create an floppy image of 1.44 MB
	fix_file_permissions "${FLOPPY_OUT}" && notify_success "successfully created the floppy image: ${FLOPPY_OUT}\n"
fi

#________________________________________________________________________________________________________________________/ Compile assembly files.
#   Use NASM to assemble the first and second stage of bootloader to an raw binary.
#   This loader is only responsible for loading the second stage from the disk and defining the file system.
#
notify "Assembling all source files..."
cd "${BOOT_DIRECTORY}" || exit      # Go to the boot directory for assembling the source files of the bootloader.
_safe_rm ${BOOT_OUT} 0              # Remove old bootstrap binary.
_safe_rm ${STAGE2_OUT} 0            # Remove old stage 2 binary.

# ASSEMBLE FIRST STAGE BOOTLOADER
notify "Assembling file: ${BOOTSTRAP_NAME}.asm to binary: ${BOOT_OUT}..."
nasm -O0 -w+orphan-labels -f bin -o ${BOOT_OUT} ${BOOTSTRAP_NAME}.asm || exit
fix_file_permissions "${BOOT_OUT}"
notify_success "successfully successfully assembled the first stage of the bootloader to an binary: ${BOOT_OUT}"

# ASSEMBLE SECOND STAGE BOOTLOADER
notify "Assembling file: ${STAGE2_NAME}.asm to binary: ${STAGE2_OUT}..."
nasm -O0 -w+orphan-labels -f bin -o ${STAGE2_OUT} ${STAGE2_NAME}.asm || exit
fix_file_permissions "${STAGE2_OUT}"
notify_success "successfully assembled the second stage of the bootloader to an binary: ${STAGE2_OUT}"

# CHANCE DIRECTORY TO SRC/KERNEL
cd "${KERNEL_DIRECTORY}" || exit    # go to the kernel directory.
_safe_rm ${KERNEL_OUT} 0            # Remove old kernel binary.

# ASSEMBLE KERNEL
notify "Assembling file: ${KERNEL_NAME}.asm to binary: ${KERNEL_OUT}..."
nasm -O0 -w+orphan-labels -f bin -o ${KERNEL_OUT} ${KERNEL_NAME}.asm || exit
fix_file_permissions "${KERNEL_OUT}"
notify_success "successfully assembled the kernel to an binary: ${KERNEL_OUT}" || exit

notify_success "Done assembling files.\n"
cd ../../

#________________________________________________________________________________________________________________________/ Install bootloader
#   Copy the first stage of the bootloader to the floppy image.
#
notify "Adding bootloader to floppy image..."
dd status=progress conv=notrunc if="${BOOT_DIRECTORY}/${BOOT_OUT}" of="${FLOPPY_OUT}" || exit
notify_success "Successfully copied ${BOOT_DIRECTORY}/${BOOT_OUT} to the floppy image: ${FLOPPY_OUT}\n"

#________________________________________________________________________________________________________________________/ Install stage2 & kernel
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
#
notify "Creating and mounting the floppy image as an loop-back device..."

if [ -d "${TEMP_FLOPPY_MOUNT}" ] ; then
    if mountpoint -q "${TEMP_FLOPPY_MOUNT}"; then
        echo "   -$(umount -v "${TEMP_FLOPPY_MOUNT}" 2>&1)"
        _safe_rm "${TEMP_FLOPPY_MOUNT}" 1
    else
        _safe_rm "${TEMP_FLOPPY_MOUNT}" 1
    fi
fi

mkdir "${TEMP_FLOPPY_MOUNT}"
notify "$( mount -v -o loop -t vfat "${FLOPPY_OUT}" "${TEMP_FLOPPY_MOUNT}" || exit )"
notify_success "Successfully mounted the floppy image at mount point: ${TEMP_FLOPPY_MOUNT}\n"

notify "Coping binaries to the floppy image..." && echo -n "\e[92m"
cp -v   "${KERNEL_DIRECTORY}/${KERNEL_OUT}" \
        "${BOOT_DIRECTORY}/${BOOT_OUT}" \
        "${TEMP_FLOPPY_MOUNT}" | sed "s/^/   -Copied file: /" && echo  "\e[39m"

sleep 0.2

notify "Unmounting floppy drive..."
echo "   -$(umount -v "${FLOPPY_OUT}" 2>&1)"  || exit

notify "Removing the temporary directory..."
_safe_rm "${TEMP_FLOPPY_MOUNT}" 2  # Remove the directory used as loop-back mount point.
notify_success "Finished creating the floppy image.\n"

#________________________________________________________________________________________________________________________/ Create CD-DISK ISO
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
#
notify "Creating CD ISO image..."

_safe_rm "${CD_OUT}" 0      # Remove the old iso.
FLOPPY_RELATIVE_PATH="$(realpath --relative-to=$(pwd)/disk_images ${FLOPPY_OUT} )"
ISO_RELATIVE_PATH="$(realpath --relative-to=$(pwd)/disk_images ${DISK_IMG_DIR} )"
echo "${CD_OUT}\n${FLOPPY_RELATIVE_PATH}\n${DISK_IMG_DIR}\n"
genisoimage -quiet -V 'JORIXOS' -input-charset iso8859-1 -o "${CD_OUT}" -b ${FLOPPY_RELATIVE_PATH} ${DISK_IMG_DIR} || exit
fix_file_permissions "${CD_OUT}"
notify_success "Successfully created an CD-ROM image: ${CD_OUT}"

print_fancy pagga "Done building!"

#________________________________________________________________________________________________________________________/ Start the OS ?
#   If the user wants it, boot the os with qemu
#
if which ponysay >/dev/null ; then ponysay "Done building, do you want to start Jorix OS? [Y/n]";
else echo "Done building, do you want to start Jorix OS? [Y/n]"; fi

read  answer # Wait for the user to decide if he want to run the build operation system.

if echo "$answer" | grep -iq "^y" ; then
    qemu-system-i386 -net none -boot a -drive format=raw,file=${FLOPPY_OUT},index=0,if=floppy
else
    notify_success "Okey, you can also run it with run.sh";
fi
exit

