#!/bin/bash
#________________________________________________________________________________________________________________________/ Configuration
# You can configure options in the section below
NAME=""                                          # By default, NAME is empty
TIMES=1                                          # By default, print greeting once

#________________________________________________________________________________________________________________________/ Variables
# Variables used by this script, you probably don't want to edit these.

#________________________________________________________________________________________________________________________/ Functions
# Functions used in this script.
usage() {                                        # Function to print a usage string.
  echo "Usage: $0 [ -n NAME ] [ -t TIMES ]" 1>&2 # Echo usage string to standard error
  exit 1                                         # Exit with error status 1
}

#________________________________________________________________________________________________________________________/ Parsing cli arguments.
# Functions used in this script.
while getopts ":n:t:" options; do                # Our getopts while loop
  case "${options}" in
    n)                                           # If the option is -n
      NAME=${OPTARG}                             # set $NAME.
      ;;
    t)
      TIMES=${OPTARG}                            # set $TIMES.
      re_isanum='^[0-9]+$'                       # regex to match whole numbers only
      if ! [[ $TIMES =~ $re_isanum ]] ; then     # if $TIMES is not a whole number...
        echo "Error: TIMES must be a positive, whole number."
        usage
      elif [ $TIMES -eq "0" ]; then              # If it's zero...
        echo "Error: TIMES must be greater than zero."
        usage
      fi
      ;;
    :)                                           # If expected argument omitted...
      echo "Error: -${OPTARG} requires an argument."
      usage
      ;;
    *)                                           # If neither option is matched...
      usage
      ;;
  esac
done
#____________










____________________________________________________________________________________________________________/ Main
# Functions used in this script.
if [ "$NAME" = "" ]; then                        # If $NAME is an empty string,
  STRING="Hi!"                                   # our greeting is just "Hi!"
else
  STRING="Hi, $NAME!"                            # otherwise, it includes $NAME
fi

COUNT=1                                          # Counter variable
while [ $COUNT -le $TIMES ]; do                  # While less than or equal to $TIMES,
  echo $STRING                                   # Print a greeting, and
  let COUNT+=1                                   # increment the counter.
done

                                       # exit normally


FANCY_PRINT=0
if [ -x  "$(command -v toilet)" ] ; then
    FANCY_PRINT=2
	toilet -t -W -f gay:border -F pagga ""
elif [ -x  "$(command -v toilet)" ] ; then
    FANCY_PRINT=1
fi

for Item in "${Emulators[@]}"
do
    if ! [ -x "$(command -v $Item)" ]; then
        echo "Error: ${Item} is not installed." >&2
    else
        echo 'Yeay the command is available'
    fi

done


  exec $Item -v foo >/dev/null 2>&1 || { BOCHS_AVAILABLE=true >&2; exit 1; }
for cmd in "latex" "pandoc"; do
  printf "%-10s" "$cmd"
  if hash "$cmd" 2>/dev/null; then printf "OK\n"; else printf "missing\n"; fi
done

BOCHS_AVAILABLE=false
QEMU_AVAILABLE=false
echo `bochs -v foo >/dev/null 2>&1 != 0`
if `builtin type -p vim` ]; then echo "TRUE"; else echo "FALSE"; fi
bochs -v foo >/dev/null 2>&1 || { BOCHS_AVAILABLE=true >&2; exit 1; }

if which qemu-system-i386 >/dev/null ; then
	QEMU_AVAILABLE=true
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

