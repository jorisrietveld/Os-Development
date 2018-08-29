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
JORIX_DIR="$(pwd)"
: ${JORIX_BUILD_CONFIG_FILE:="${JORIX_DIR}/bash-scripts.config"}
#________________________________________________________________________________________________________________________/ Options
# File privileges for the generated files.
: ${OUTPUT_PRIVILEGE_USER:="joris"}             # Replace this with your normal username or leave empty for auto detect.
: ${OUTPUT_PRIVILEGE_LEVEL:="777"}              # File privileges on compiled binaries, 777 is bad

# Some standard locations.
: ${SRC_DIR_BOOT:="${JORIX_DIR}/src/boot"}      # The location of source code of the bootloader.
: ${SRC_DIR_KERNEL="${JORIX_DIR}/src/kernel"}   # The location of assembly source code of the kernel.
: ${OUT_DIR_IMAGES:="${JORIX_DIR}/disk_images"} # The location of bootable disk images.
: ${OUT_DIR_BOOT:="${SRC_DIR_BOOT}"}            # The location of the compiled bootloader.
: ${OUT_DIR_KERNEL="${SRC_DIR_KERNEL}"}         # The location of the compiled assembly kernel.

# The base names of the source files.
: ${BOOTSTRAP_BASE:="bootstrap"}                # The name of 512 byte bootstrap loader.
: ${BOOTLOADER_BASE:="stage2"}                  # The name of kernel-loader/stage2-bootloader.
: ${KERNEL_ASM_BASE:="kernel"}                  # The name of the first kernel written in assembly.
: ${DISK_IMAGE_BASE:="JorixOS"}                 # The name of the disk images that will be created.

# Generated binaries and images by the script
: ${BOOTSTRAP_OUT:="${BOOTSTRAP_BASE}.bin"}     # The bootstrap binary, gets copied in the first sector of the image.
: ${BOOTLOADER_OUT:="${BOOTLOADER_BASE}.bin"}   # The second stage, gets copied on the FAT12's root directory.
: ${KERNEL_ASM_OUT:="KRNL.SYS"}                 # The kernel written is asm also stored on the root directory.
: ${FLOPPY_IMAGE_OUT:="${DISK_IMAGE_BASE}.flp"} # The name of bootable floppy image.
: ${CD_ISO_IMAGE_OUT:="${DISK_IMAGE_BASE}.iso"} # The name of bootable cd disk image converted from the floppy.

# The files containing the assembly source code
: ${BOOTSTRAP_IN:="${BOOTSTRAP_BASE}.asm"}      # Source of the bootstrap bootloader (located in first 512 bytes).
: ${BOOTLOADER_IN:="${BOOTLOADER_BASE}.asm"}    # Source of the second stage of the bootloader, loads the kernel.
: ${KERNEL_ASM_IN:="${KERNEL_ASM_BASE}.asm"}    # Source of the first kernel version still written in assembly.

TEMP_FLOPPY_MOUNT="${JORIX_DIR}/loopback_flp"

CACHE_DIR="${JORIX_DIR}/.cache"
CACHE_FONT_FILE=".fonts.cache"

# The color settings in bash escape codes for the output messages.
# In the format: "Attribute:Foreground;Background", like this: 1;32;40 = bold;green;black
: ${COLOR_INFO:="96;49"}                        # \e[ Blue:Default
: ${COLOR_DEBUG:="1;97;49"}                     # \e[ Bold;White:Default
: ${COLOR_SUCCESS:="92;49"}                     # \e[ Green;Default
: ${COLOR_ERROR:="91;49"}                       # \e[ Red;Default
: ${COLOR_WARNING:="93;49"}                     # \e[ Yellow;Default
: ${COLOR_QUESTION:="7;92;49"}                  # \e[ Inverted;Green;Default

# The amount of output to show in the console.
# Level: 1 error
# Level: 2 error, status, success, warning
# Level: 3 error, status, success, warning, debug
: ${DBG:=3}

# Disables the question
: ${DISABLE_QUESTION:=0}

GENERATED_BUILD_FILES=()                # For internal use, do not add elements to them.
GENERATED_DISK_IMAGES=()                # For internal use, do not add elements to them.
#________________________________________________________________________________________________________________________/ Helper print functions
notify_about(){
    TEXT="${1}"
    COLOR_START="\e[${2}m"
    ICON="${3}"
    printf '%b \e[1m%b\e[21m %b \e[0m\n' "${COLOR_START}" "${ICON}" "${TEXT}"
}
notify_status(){
    declare TEXT_INPUT=${*:-$(</dev/stdin)}
    (($DBG > 1)) || return 0
    for PARAM in "${TEXT_INPUT}"; do notify_about "${PARAM}" "${COLOR_INFO}" "➔"; done
}
notify_debug(){
    declare DEBUG_INPUT=${*:-$(</dev/stdin)}
    (($DBG > 2)) || return 0
    for PARAM in "${DEBUG_INPUT}"; do notify_about "${PARAM}" "${COLOR_DEBUG}" "▶"; done
}
extra_debug(){
    declare DEBUG_INPUT=${*:-$(</dev/stdin)}
      (($DBG > 2)) || return 0
    for PARAM in "${DEBUG_INPUT}"; do notify_about "${PARAM}" "${COLOR_DEBUG}" "  ↳"; done
}
notify_success(){
    declare DEBUG_INPUT=${*:-$(</dev/stdin)}
    (($DBG > 1)) || return 0
    for PARAM in "${DEBUG_INPUT}"; do notify_about "${PARAM}" "${COLOR_SUCCESS}" "√"; done
}
notify_error(){
    declare DEBUG_INPUT=${*:-$(</dev/stdin)}
    for PARAM in "${DEBUG_INPUT}"; do notify_about "${PARAM}" "${COLOR_ERROR}\a" "❎"; done
}
notify_warning(){
    declare DEBUG_INPUT=${*:-$(</dev/stdin)}
    (($DBG > 1)) || return 0
    for PARAM in "${DEBUG_INPUT}"; do notify_about "${PARAM}" "${COLOR_WARNING}" "⚠"; done
}
notify_question(){
    notify_about "${1}" "${2:-${COLOR_QUESTION}}" "${3:-⁉}";
}
print_fancy(){
    if which toilet >/dev/null 2>&1; then
    echo " "
        toilet -t -F gay -f $1 $2
    elif which figlet >/dev/null 2>&1; then
        figlet $1 $2
    else
        echo $2;
    fi
}
fix_file_permissions(){
    if [ -f "${1}" ] ; then
        chmod "${OUTPUT_PRIVILEGE_LEVEL}" "${1}"
        chmod "${OUTPUT_PRIVILEGE_LEVEL}" "${1}"
        GENERATED_BUILD_FILES+=("$(pwd)/${1}")
    else
        notify_error "Error updating file permissions, because the file ${NAME_OF_CREATED_FILE} does not exist."
        #notify_error "Currently in directory: $(pwd), Files in this directory:"
        notify_error "Files in directory: $(pwd)"
        ls -F | sed "s/^/$(printf "\e[91m\t")|-/" && echo
        exit
    fi
}
# safe_remove? [filename] [type]
_safe_rm(){
    FILE_TO_REMOVE="$1"
    TYPE="$2"
    if [ ! -e "${FILE_TO_REMOVE}" ]; then
        notify_error "The file ${FILE_TO_REMOVE} does not exist.";
    elif [ -f "${FILE_TO_REMOVE}" ] && [ "${2}" -eq 0 ]; then
         rm -v "${FILE_TO_REMOVE}" | extra_debug
    elif [ -d "${FILE_TO_REMOVE}" ] && [ "${2}" -eq 1 ]; then
         rm -v -rf "${FILE_TO_REMOVE}" | extra_debug
    else
        notify_error "Error type not specified or incorrect, 0=file and 1=directory. Supplied type: ${2}" ;
    fi
}
#________________________________________________________________________________________________________________________/ Check root
#   Check if the executing user is root, this is needed to mount the loop-back device for creating the floppy image.
#   Test if the user has root privileges, this is needed for creating the disk image.
if test "$(whoami)" != "root" ; then
    print_fancy smmono12 "You shall not pass!"
    notify_error "You have to have root privileges for building the operating system."
	print_fancy pagga "Try again with god mode enabled." && exit
else
    printf '%80s\n' | tr ' ' = && print_fancy mono12 "Jorix OS" && printf '%80s\n\n' | tr ' ' =
fi
sleep 0.5
#________________________________________________________________________________________________________________________/ Check User Config
notify_debug "Detecting configured user for the ownership of generated files..."
if id "${OUTPUT_PRIVILEGE_USER}" >/dev/null 2>&1 || getent passwd "${OUTPUT_PRIVILEGE_USER}"; then
    extra_debug "All generated files will be owned by: ${OUTPUT_PRIVILEGE_USER}."
else
    notify_warning "The configured user:${OUTPUT_PRIVILEGE_USER} does not exist."
    notify_debug "Automatic user detection..."
    OUTPUT_PRIVILEGE_USER=${SUDO_USER:-$(whoami)}
    extra_debug "All generated files will be owned by: ${OUTPUT_PRIVILEGE_USER}."
fi

#________________________________________________________________________________________________________________________/ Make empty Floppy image
#   Check if there is an floppy image that can be used to write the operating system to. If it isn't is will create
#   an floppy image with 1.44 MB storage.
#
if [ ! -e "${OUT_DIR_IMAGES}/${FLOPPY_IMAGE_OUT}" ] ; then
    notify_debug "> Creating new floppy image..."
	mkdosfs -v -C "${OUT_DIR_IMAGES}/${FLOPPY_IMAGE_OUT}" 1440 || exit   # Create an floppy image of 1.44 MB
	fix_file_permissions "${OUT_DIR_IMAGES}/${FLOPPY_IMAGE_OUT}" && notify_success "successfully created the floppy image: ${FLOPPY_OUT}"
fi
GENERATED_DISK_IMAGES+=("${FLOPPY_IMAGE_OUT}")

#________________________________________________________________________________________________________________________/ Compile assembly files.
#   Use NASM to assemble the first and second stage of bootloader to an raw binary.
#   This loader is only responsible for loading the second stage from the disk and defining the file system.
notify_status "Start Assembling source files..."

# Go to the boot directory for assembling the source files of the bootloader.
cd "${SRC_DIR_BOOT}" && pwd | sed 's/^/Move to directory: /' | notify_debug || exit

# Clean up...
_safe_rm ${BOOTSTRAP_OUT} 0                     # Remove old bootstrap binary.
_safe_rm ${BOOTLOADER_OUT} 0                    # Remove old stage 2 binary.

# Assemble first stage bootloader...
notify_debug "Assembling file: ${BOOTSTRAP_BASE}.asm to binary: ${BOOTSTRAP_OUT}..."
nasm -Xgnu -O0v -w+orphan-labels -f bin -o ${BOOTSTRAP_OUT} ${BOOTSTRAP_BASE}.asm 2>&1|extra_debug|| exit
fix_file_permissions "${BOOTSTRAP_OUT}"
notify_success "successfully successfully assembled the first stage of the bootloader to an binary: ${BOOTSTRAP_OUT}"

# Assemble second stage bootloader..
notify_debug "Assembling file: ${BOOTLOADER_BASE}.asm to binary: ${BOOTLOADER_OUT}..."
nasm -Xgnu -O0v -w+orphan-labels -f bin -o ${BOOTLOADER_OUT} ${BOOTLOADER_BASE}.asm 2>&1|extra_debug|| exit
fix_file_permissions "${BOOTLOADER_OUT}"
notify_success "successfully assembled the second stage of the bootloader to an binary: ${BOOTLOADER_OUT}"

# Go to the boot directory for assembling the source files of the kernel.
cd "${SRC_DIR_KERNEL}" && pwd|sed 's/^/Move to directory: /'|notify_debug || exit
_safe_rm ${KERNEL_ASM_OUT} 0         # Remove old kernel binary.

# Assemble the kernel.
notify_debug "Assembling file: ${KERNEL_ASM_BASE}.asm to binary: ${KERNEL_ASM_OUT}..."
nasm -Xgnu -O0v -w+orphan-labels -f bin -o ${KERNEL_ASM_OUT} ${KERNEL_ASM_BASE}.asm 2>&1|extra_debug|| exit
fix_file_permissions "${KERNEL_ASM_OUT}"
notify_success "successfully assembled the kernel to an binary: ${KERNEL_ASM_OUT}" || exit

notify_success "Done assembling files.\n"
cd ../../ && pwd|sed 's/^/Move to directory: /'|notify_debug || exit

#________________________________________________________________________________________________________________________/ Install bootloader
#   Copy the first stage of the bootloader to the floppy image.
notify_status "Adding the bootloader to the floppy image..."
dd  status=progress conv=notrunc if="${SRC_DIR_BOOT}/${BOOTSTRAP_OUT}" of="${FLOPPY_OUT}" 2>&1|sed "s/^/dd stat: /"|while read -r;
do extra_debug "${REPLY}";
done || exit
notify_success "Successfully copied ${BOOTSTRAP_OUT} to the floppy image: ${FLOPPY_OUT}\n"

#________________________________________________________________________________________________________________________/ Install stage2 & kernel
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
notify_status "Creating and mounting the floppy image as an loop-back device..."
if [ -d "${TEMP_FLOPPY_MOUNT}" ] ; then
    if mountpoint -q "${TEMP_FLOPPY_MOUNT}"; then
        umount -v "${TEMP_FLOPPY_MOUNT}" 2>&1|extra_debug
        _safe_rm "${TEMP_FLOPPY_MOUNT}" 1
    else
        _safe_rm "${TEMP_FLOPPY_MOUNT}" 1
    fi
fi

mkdir "${TEMP_FLOPPY_MOUNT}"
mount -v -o loop -t vfat "${OUT_DIR_IMAGES}/${FLOPPY_IMAGE_OUT}" "${TEMP_FLOPPY_MOUNT}" 2>&1 | extra_debug || exit
notify_success "Successfully mounted the floppy image at mount point: ${TEMP_FLOPPY_MOUNT}\n"

#________________________________________________________________________________________________________________________/ Adding files to floppy.
notify_status "Coping binaries to the floppy image..."
cp -v   "${SRC_DIR_KERNEL}/${KERNEL_ASM_OUT}" \
        "${SRC_DIR_BOOT}/${BOOTSTRAP_OUT}" \
        "${TEMP_FLOPPY_MOUNT}" |sed 's/^/Copied: /' | while read -r;
        do extra_debug "${REPLY}";
        done || exit

sleep 0.2

notify_debug "Unmounting floppy drive..."
umount -v "${TEMP_FLOPPY_MOUNT}" 2>&1 | extra_debug

notify_debug "Removing the temporary directory..."
_safe_rm "${TEMP_FLOPPY_MOUNT}" 1  # Remove the directory used as loop-back mount point.
notify_success "Finished creating the floppy image.\n"

#________________________________________________________________________________________________________________________/ Create CD-DISK ISO
#   Copy the second stage of the bootloader to the floppy image. It does this by mounting the floppy image virtually to
#   an temporary location and just coping the binaries to it.
notify_status "Creating CD ISO image..."
cd "${OUT_DIR_IMAGES}" && pwd|sed 's/^/Move to directory: /'|notify_debug || exit
_safe_rm "${CD_ISO_IMAGE_OUT}" 0      # Remove the old iso.

notify_debug "Converting floppy image to CD ISO..."
genisoimage  -V 'JORIXOS' -input-charset iso8859-1 \
    -o "${CD_ISO_IMAGE_OUT}" \
    -b "${FLOPPY_IMAGE_OUT}" ${OUT_DIR_IMAGES} 2>&1 | while read -r;
    do extra_debug "${REPLY}";
    done || exit
chown "${OUTPUT_PRIVILEGE_USER}" "${CD_ISO_IMAGE_OUT}"
chmod "${OUTPUT_PRIVILEGE_LEVEL}" "${CD_ISO_IMAGE_OUT}"
GENERATED_DISK_IMAGES+=("${CD_ISO_IMAGE_OUT}")

notify_success "Successfully created an CD-ROM image: ${CD_OUT}\n"

#________________________________________________________________________________________________________________________/ Done building!
#   If the user wants it, boot the os with qemu
print_fancy pagga "Done building!"
echo

#________________________________________________________________________________________________________________________/ Cleanup
#   If the user wants it, boot the os with qemu
if(( $DBG > 1 )) && (( $DISABLE_QUESTION == 0 )); then
    notify_debug "The build script has generated the following files:"
    for i in "${GENERATED_BUILD_FILES[@]}"; do
        extra_debug "$i"
    done
    notify_question "Do you want to clean the building area, by removing all generated binaries?"

    if read -r -p "$(printf '\e[7;92m%s:' "Remove them? (y/N)" )" && echo "$REPLY"| grep -iq "^y"; then

        # Create an list of all files that can be deleted.
        notify_question "Are you sure you want to remove the following files:" "1;7;91;49"
        for removeFile in ${GENERATED_BUILD_FILES[@]}; do
            notify_question "${removeFile}" "91;49" "✘"
        done
        if read -r -p "$(printf '\e[7;91m%s:' "Archive to /dev/null? (y/N)" )" && echo "$REPLY"| grep -iq "^y"; then
            echo -en "\e[0m" &&  notify_debug "Removing build files..."
            for removeFile in ${GENERATED_BUILD_FILES[@]}; do
                _safe_rm "${removeFile}" 0
            done
        fi
    fi

fi
#________________________________________________________________________________________________________________________/ Start the OS ?
#   If the user wants it, boot the os with qemu
if which ponysay >/dev/null ; then ponysay "Done building, do you want to start Jorix OS? [Y/n]";
else echo "Done building, do you want to start Jorix OS? [Y/n]"; fi

read  answer # Wait for the user to decide if he want to run the build operation system.

if echo "$answer" | grep -iq "^y" ; then
    qemu-system-i386 -net none -boot a -drive format=raw,file=${FLOPPY_OUT},index=0,if=floppy
else
    notify_success "Okey, you can also run it with run.sh";
fi













# ᙭ ⚠ ‼ ‽ ⁉ ↳ ⇉ ⇏ ⇛ ⇝ ⇢ ⇥ ⇨ ⇰ ⇶ ≫ ⊗ ⊖ ⊕ ⊘ ⊛ ⊢ ⊪ ⊱ ⊳ ⋐ ⋑ ⋙ ⌦ ↬ ✅ ✖ ✗ ↦ ✘ ❱➔➲ ⟶⧐  ↬₶₳₵₭₹ ℍ₳℃₭₹ ℌ<₳℃₭₹ ℋ₳℃₭₹❌ ❎ ✓ ✔ ✗ ✘ ☐ ☑ ☒
