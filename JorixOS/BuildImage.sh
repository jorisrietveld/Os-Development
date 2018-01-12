#!/usr/bin/env bash
# Get the name of the script and save it to an read only variable.
declare -r BUILD_SCRIPT="$0"

# Get the project source directory and save it to an read only variable.
declare -r JORIX_SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get user name of the sudoer and save it to an read only variable.
declare -r OUT_USER="${SUDO_USER:-$(whoami)}"

# Assemble the fist stage bootloader.
declare -r STAGE1="${JORIX_SRC_DIR}/bootstrap.bin"      # Name of the generated binary first stage bootloader.
rm -f "$STAGE1"                                         # Remove previously generated binaries.
nasm -f bin first_stage.asm -o "$STAGE1" || exit 1      # Assemble the first stage.
echo "size of $STAGE1 is: $(stat -c "%s" "$STAGE1")"    # Print the file size of generated binary.
hexdump "$STAGE1"                                       # Dump the generated binary to the shell.

# Assemble the second stage bootloader.
declare -r STAGE2="${JORIX_SRC_DIR}/stage2.bin"         # Name of the generated binary second stage bootloader.
rm -f "$STAGE2"                                         # Remove previously generated binaries.
nasm -f bin second_stage.asm -o "$STAGE2" || exit 1     # Assemble the second stage.
echo "size of $STAGE1 is: $(stat -c "%s" "$STAGE2")"    # Print the file size of generated binary.
hexdump "$STAGE2"                                       # Dump the generated binary to the shell.

# Make an directory for temporary mounting an floppy image.
declare -r MNT="/tmp/tmp-floppy-loop"                   # Name of temporary mount point directory.
rm -rf "$MNT" || (umount "$MNT" && rm -rf "$MNT")       # Remove the mount old directory (unmount if mounted).
mkdir "$MNT" || exit 1                                  # Make mount directory.
chmod 777 "$MNT" || exit 1                              # Set the permissions.
chown "$OUT_USER" "$MNT" || exit 1                      # Take ownership of the directory.
echo "Created an temporary directory to mount floppy."
echo ls -l "${MNT}"

# Make an floppy image.
declare -r FLOPPY_IMAGE="${JORIX_SRC_DIR}/JorixOS.flp"  # Name of the bootable floppy image file.
rm -f "$FLOPPY_IMAGE"                                   # Remove old floppy image.
mkdosfs -C "$FLOPPY_IMAGE" 1440 || exit 1               # Make floppy image.
chmod 777 "$FLOPPY_IMAGE" || exit 1                     # Set the permissions.
chown "$OUT_USER" "$FLOPPY_IMAGE" ||exit 1              # Take ownership of the directory.
echo "Created an bootable floppy image of the JorixOS."
echo ls -l "${FLOPPY_IMAGE}"

# Install all files on the floppy image
dd  status=progress                                    `# Set dd to print the status of the operation.` \
    conv=notrunc                                       `# Write the first stage to start without altering the rest.` \
    if="${STAGE1}"                                     `# The input file for dd, this is the first stage binary.` \
    of="${FLOPPY_IMAGE}" || exit 1                      # The output file for dd, this is the floppy image.
mount -v -o loop -t vfat ${FLOPPY_IMAGE} ${MNT} || exit 1  # Mount the image, To mount directory

cp -v "${STAGE2}" "${MNT}" || exit 1                    # Copy the second stage binary on to the mounted floppy image.

umount -v "${MNT}"                                      # Unmount the floppy image.
umount -v "/dev/loop0"                                  # Unmount the floppy image.
rm -rf "${MNT}"                                         # Remove the temporary directory.

# Start the operating system in the emulator.
qemu-system-i386 -net none                                     `# Start qemu i386 emulator.` \
    -net none                                                  `# Disable PXE, net boot.` \
    -boot a                                                    `# Set first boot device to the floppy drive.` \
    -drive format=raw,file="$FLOPPY_IMAGE",index=0,if=floppy    # Insert the image into the floppy drive.
