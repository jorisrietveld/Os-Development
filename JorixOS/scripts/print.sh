#!/usr/bin/env bash
: ${ENABLE_FANCY_HEADERS:=1}
: ${FANCY_HEADER_PROGRAM:="toilet"}

  if which toilet >/dev/null 2>&1; then
    echo " "
        toilet -t -F gay -f $1 $2
    elif which figlet >/dev/null 2>&1; then
        figlet $1 $2
    else
        echo $2;
    fi

HEADER_FONT=""

