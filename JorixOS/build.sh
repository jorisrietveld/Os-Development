#!/bin/bash
#                                                                                       ,   ,           ( VERSION 0.0.3
#                                                                                         $,  $,     ,   `̅̅̅̅̅̅( 0x003
#                                                                                         "ss.$ss. .s'          `̅̅̅̅̅̅
#   MMMMMMMM""M MMP"""""YMM MM"""""""`MM M""M M""MMMM""M                          ,     .ss$$$$$$$$$$s,
#   MMMMMMMM  M M' .mmm. `M MM  mmmm,  M M  M M  `MM'  M                          $. s$$$$$$$$$$$$$$`$$Ss
#   MMMMMMMM  M M  MMMMM  M M'        .M M  M MM.    .MM    .d8888b. .d8888b.     "$$$$$$$$$$$$$$$$$$o$$$       ,
#   MMMMMMMM  M M  MMMMM  M MM  MMMb. "M M  M M  .mm.  M    88'  `88 Y8ooooo.    s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
#   M. `MMM' .M M. `MMM' .M MM  MMMMM  M M  M M  MMMM  M    88.  .88       88   s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
#   MM.     .MM MMb     dMM MM  MMMMM  M M  M M  MMMM  M    `88888P' `88888P'   s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
#   MMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMMM MMMM MMMMMMMMMM                       s$$$$$$$$$$'         `"""ss"$"$s""
#                                                                               s$$$$$$$$$$,              `"""""$  .s$$s
#   ______[  Author ]______    ______[  Contact ]_______                        s$$$$$$$$$$$$s,...               `s$$'  `
#      Joris Rietveld           jorisrietveld@gmail.com                       sss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
#                                                                             `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
#   _______________[ Website & Source  ]________________                           "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
#       https://github.com/jorisrietveld/Os-Development                              "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
#                                                                                     $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
#   ___________________[ Licence ]______________________                             $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
#             General Public licence version 3                                  ,   ,"     '  $$$$$$$$$$$$$$$$####s
#   ===============================================================================================================    #
#                                                                                                Build & Run Script    #
#   How to build & run:                                                                          ̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅̅    #
#   _[Step 1]_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                                               #
#   Downloading the repo :                                                                                             #
#       git clone https://github.com/jorisrietveld/Os-Development.git                                                  #
#   Set file permissions :                                                                                             #
#       chmod 644 ./Os-Development/ -R && 744 Os-Development/build.sh && cd Os-Development/                            #
#                                                                                                                      #
#   _[Step 2]_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                                               #
#   Optionally alter the config:                                                                                       #
#       nano ./build.sh || vi ./build.sh || emacs ./build.sh                                                           #
#                                                                                                                      #
#   _[Step 3]_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                                               #
#   Finally execute this script with sudo (Needed mounting floppy drive when creating the image:                       #
#       sudo ./build.sh                                                                                                #
#                                                                                                                      #
#   _[Step 4]_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                                               #
#   You will be prompted for additional configuration, if the building is done you can choose to automatically start   #
#   an emulator (if you have something like bochs or qemu installed).                                                  #
#                                                                                                                      #
#   _[Step 5]_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                                               #
#   Give me some feedback, ask a question or a flame over stupid design decisions, I would appreciate it.              #
#   Just open a issue on github at https://github.com/jorisrietveld/Os-Development/issues/new                          #
#                                                                                                                      #
#   Created on: 04-01-2017 04:09                                                                                       #
#
JORIX_DIR="`pwd`"
: ${JORIX_BUILD_CONFIG_FILE:="${JORIX_DIR}/bash-scripts.config"}
#________________________________________________________________________________________________________________________/ Options
# File privileges for the generated files.
: ${OUTPUT_PRIVILEGE_USER:="joris"}             # Replace this with your normal username or leave empty for auto detect.
: ${OUTPUT_PRIVILEGE_LEVEL:="777"}              # File privileges on compiled binaries, 777 is bad

# Some standard locations.
: ${OUT_DIR_IMAGES:="${JORIX_DIR}/disk_images"} # The directory containing bootable disk images.
: ${SRC_DIR_BOOT:="${JORIX_DIR}/src/boot"}      # The directory containing source code of the bootloader.
: ${SRC_DIR_KERNEL="${JORIX_DIR}/src/kernel"}   # The directory containing source code of the bootloader.

# The base names of the source files.
: ${BOOTSTRAP_BASE:="bootstrap"}                # The name of 512 byte bootstrap loader.
: ${BOOTLOADER_BASE:="stage2"}                  # The name of kernel-loader/stage2-bootloader.
: ${KERNEL_ASM_BASE:="kernel"}                  # The name of the first kernel written in assembly.
: ${DISK_IMAGE_BASE:="JorixOS"}                 # The name of the disk images that will be created.

# Generated binaries and images by the script
: ${BOOTSTRAP_OUT:="${BOOTSTRAP_BASE}.bin"}     # The bootstrap binary, gets copied in the first sector of the image.
: ${BOOTLOADER_OUT:="${BOOTLOADER_BASE}.bin"}   # The second stage, gets copied on the FAT12's root directory.
: ${KERNEL_ASM_OUT:="KRNL.SYS"}                 # The kernel written is asm also stored on the root directory.
: ${FLOPPY_IMAGE_OUT:="${BOOTLOADER_BASE}.flp"} # The name of bootable floppy image.
: ${CD_ISO_IMAGE_OUT:="${BOOTLOADER_BASE}.iso"} # The name of bootable cd disk image converted from the floppy.

# The files containing the assembly source code
: ${BOOTSTRAP_IN:="${BOOTSTRAP_BASE}.asm"}      # Source of the bootstrap bootloader (located in first 512 bytes).
: ${BOOTLOADER_IN:="${BOOTLOADER_BASE}.asm"}    # Source of the second stage of the bootloader, loads the kernel.
: ${KERNEL_ASM_IN:="${KERNEL_ASM_BASE}.asm"}    # Source of the first kernel version still written in assembly.

FLOPPY_OUT="${OUT_DIR_IMAGES}/${DISK_IMAGE_BASE}.flp"      # The absolute path + floppy_image.flp to be created.
CD_OUT="${OUT_DIR_IMAGES}/${DISK_IMAGE_BASE}.iso"          # The absolute path + floppy_image.flp to be created.
TEMP_FLOPPY_MOUNT="${JORIX_DIR}/loopback_flp"

GENERATED_BUILD_FILES=()                        # For internal use, do not add elements to them.
GENERATED_DISK_IMAGES=()                        # For internal use, do not add elements to them.

CACHE_DIR="${JORIX_DIR}/.cache"
CACHE_FONT_FILE=".fonts.cache"
#________________________________________________________________________________________________________________________/ Helper print functions


# Use this to set the new config value, needs 2 parameters.
# You could check that $1 and $1 is set, but I am lazy
#function set_config(){
#    sudo sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" $CONFIG
#}
#
## INITIALIZE CONFIG IF IT'S MISSING
#if [ ! -e "${CONFIG}" ] ; then
#    # Set default variable value
#    sudo touch $CONFIG
#    echo "myname=\"Test\"" | sudo tee --append $CONFIG
#fi
#
## LOAD THE CONFIG FILE
#source $CONFIG
#
#echo "${myname}" # SHOULD OUTPUT DEFAULT (test) ON FIRST RUN
#myname="Erl"
#echo "${myname}" # SHOULD OUTPUT Erl
#set_config myname $myname # SETS THE NEW VALUE
notify_about(){
    _txt="$1"
    _colorSt="\e[$2m"
    _ico="$3"
    _colorAf="\e[${4:-"39"}m"

    printf "$(_colorSt) $(_icon) $(_txt) $(_colorAf)\n"
}

notify(){
    printf "\e[49m ► $1\e[39m"
}

notify_success(){   echo "\e[92m ✓ $1\e[39m"; }
notify_error(){     echo "\e[91m ✗ $1\e[39m"; }
notify_warning(){
    notify_about "$1" "93" "⚠"
}
notify_warning "Hello world"
cmd_exists(){ "$1" -v >/dev/null 2>&1; }
print_fancy(){
    if cmd_exists toilet ; then
        toilet -t -F gay:border -f $1 $2
    elif cmd_exists figlet ; then
        figlet $1 $2
    else
        echo $2;
    fi
}

fix_file_permissions(){
    NAME_OF_CREATED_FILE="$1"

    if [ -f "${NAME_OF_CREATED_FILE}" ] ; then
        chmod "${OUTPUT_PRIVILEGE_LEVEL}" "${NAME_OF_CREATED_FILE}"
        chown "${OUTPUT_PRIVILEGE_USER}" "${NAME_OF_CREATED_FILE}"
        GENERATED_DISK_IMAGES+=("$(pwd)/${GENERATED_BUILD_FILES}")
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
    if [ ! -e "${FILE_TO_REMOVE}" ]
        then notify_error "The file ${FILE_TO_REMOVE} does not exist.";
    elif [ -f "${FILE_TO_REMOVE}" ] && [ "${TYPE}" -eq 0 ]
        then rm -v "${FILE_TO_REMOVE}" | sed "s/^/   $(printf "\e[4m\e[34m[Removing file]\e[0m\e[39m") /"
    elif [ -d "${FILE_TO_REMOVE}" ] && [ "${TYPE}" -eq 1 ]
        then rm -v -rf "${FILE_TO_REMOVE}" | sed "s/^/   $(printf "\e[4m\e[34m[Removing directory]\e[0m\e[39m") /"
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

#________________________________________________________________________________________________________________________/ Check User Config
#USER_EXISTSENCE_CNT=0
#if id "${OUTPUT_PRIVILEGE_USER}" >/dev/null 2>&1 eq 0 ; then ${USER_EXISTSENCE_CNT}++; fi
#if [ $(getent passwd "${OUTPUT_PRIVILEGE_USER}" | wc -c || 0 ) -gt 0 ] ; then ${USER_EXISTSENCE_CNT}++; fi
#
#if ${USER_EXISTSENCE_CNT} -eq 0;
#
#${SUDO_USER:-$(whoami)}


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
cd "${SRC_DIR_BOOT}" || exit      # Go to the boot directory for assembling the source files of the bootloader.
pwd | sed "s/^/   $(printf "\e[4m\e[96m[move to directory]\e[39m\e[0m\e[39m") /" || exit
_safe_rm ${BOOTSTRAP_OUT} 0              # Remove old bootstrap binary.
_safe_rm ${BOOTLOADER_OUT} 0            # Remove old stage 2 binary.

# ASSEMBLE FIRST STAGE BOOTLOADER
notify "Assembling file: ${BOOTSTRAP_BASE}.asm to binary: ${BOOTSTRAP_OUT}..."
nasm    -Xgnu -O0v -w+orphan-labels -f bin -o ${BOOTSTRAP_OUT} ${BOOTSTRAP_BASE}.asm \
        2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[nasm stats]\e[0m\e[39m") /" || exit

fix_file_permissions "${BOOTSTRAP_OUT}"
notify_success "successfully successfully assembled the first stage of the bootloader to an binary: ${BOOTSTRAP_OUT}\n"

# ASSEMBLE SECOND STAGE BOOTLOADER
notify "Assembling file: ${BOOTLOADER_BASE}.asm to binary: ${BOOTLOADER_OUT}..."
nasm    -Xgnu -O0v -w+orphan-labels -f bin -o ${BOOTLOADER_OUT} ${BOOTLOADER_BASE}.asm \
        2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[nasm stats]\e[39m\e[0m\e[39m") /" || exit

fix_file_permissions "${BOOTLOADER_OUT}"
notify_success "successfully assembled the second stage of the bootloader to an binary: ${BOOTLOADER_OUT}\n"

# CHANCE DIRECTORY TO SRC/KERNEL
cd "${SRC_DIR_KERNEL}" || exit    # go to the kernel directory.
pwd | sed "s/^/   $(printf "\e[4m\e[96m[move to directory]\e[39m\e[0m\e[39m") /" || exit
_safe_rm ${KERNEL_ASM_OUT} 0            # Remove old kernel binary.

# ASSEMBLE KERNEL
notify "Assembling file: ${KERNEL_ASM_BASE}.asm to binary: ${KERNEL_ASM_OUT}..."
nasm    -Xgnu -O0v -w+orphan-labels -f bin -o ${KERNEL_ASM_OUT} ${KERNEL_ASM_BASE}.asm \
        2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[nasm stats]\e[0m\e[39m") /" || exit

fix_file_permissions "${KERNEL_ASM_OUT}"
notify_success "successfully assembled the kernel to an binary: ${KERNEL_ASM_OUT}\n" || exit

notify_success "Done assembling files.\n"
cd ../../
pwd | sed "s/^/   $(printf "\e[4m\e[96m[move to directory]\e[39m\e[0m\e[39m") /" || exit
#________________________________________________________________________________________________________________________/ Install bootloader
#   Copy the first stage of the bootloader to the floppy image.
#
notify "Adding bootloader to floppy image..."
dd  status=progress conv=notrunc \
    if="${SRC_DIR_BOOT}/${BOOTSTRAP_OUT}" \
    of="${FLOPPY_OUT}" \
    2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[dd]\e[0m\e[39m") /" || exit

notify_success "Successfully copied ${SRC_DIR_BOOT}/${BOOTSTRAP_OUT} to the floppy image: ${FLOPPY_OUT}\n"

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
mount -v -o loop -t vfat "${FLOPPY_OUT}" "${TEMP_FLOPPY_MOUNT}" 2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[mount device]\e[0m\e[39m") /" || exit
notify_success "Successfully mounted the floppy image at mount point: ${TEMP_FLOPPY_MOUNT}\n"

notify "Coping binaries to the floppy image..."
cp -v   "${SRC_DIR_KERNEL}/${KERNEL_ASM_OUT}" \
        "${SRC_DIR_BOOT}/${BOOTSTRAP_OUT}" \
        "${TEMP_FLOPPY_MOUNT}" | sed "s/^/   $(printf "\e[4m\e[34m[cp file]\e[0m\e[39m") /"

sleep 0.2

notify "Unmounting floppy drive..."
umount -v "${FLOPPY_OUT}" 2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[Unmount device]\e[0m\e[39m") /"

notify "Removing the temporary directory..."
_safe_rm "${TEMP_FLOPPY_MOUNT}" 1  # Remove the directory used as loop-back mount point.
notify_success "Finished creating the floppy image.\n"

#________________________________________________________________________________________________________________________/ Create CD-DISK ISO
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
#
notify "Creating CD ISO image..."

notify "Deleting old iso files..."
_safe_rm "${CD_OUT}" 0      # Remove the old iso.

notify "Converting floppy image to CD ISO..."
genisoimage  -V 'JORIXOS' -input-charset iso8859-1 \
            -o "${CD_OUT}" \
            -b "$(realpath --relative-to="${OUT_DIR_IMAGES}" "${FLOPPY_OUT}")" \
            ${OUT_DIR_IMAGES} 2>&1 | sed "s/^/   $(printf "\e[4m\e[34m[genisoimage]\e[0m\e[39m") /" || exit

fix_file_permissions "${CD_OUT}"
notify_success "Successfully created an CD-ROM image: ${CD_OUT}\n"
print_fancy pagga "Done building!"
#________________________________________________________________________________________________________________________/ Cleanup
#   If the user wants it, boot the os with qemu
notify "The build script has generated the following files:"
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

