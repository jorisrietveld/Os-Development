;__________________________________________________________________________________________/ jorix_debug.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 07-06-2018 18:25
;   
;   Description:
;   This are some functions and constants for printing debug messages.
%ifdef JORIX_DEBUG_LEVEL
%ifndef __JORIX_DEBUG_INC_INCLUDED__
%define __JORIX_DEBUG_INC_INCLUDED__

%include 'libs/common.inc'

%define JX_DBG_LEVEL_EMERGENCY 0        ;
%define JX_DBG_LEVEL_ALERT 1            ;
%define JX_DBG_LEVEL_CRITICAL 2         ;
%define JX_DBG_LEVEL_ERROR 3            ;
%define JX_DBG_LEVEL_WARNING 4          ;
%define JX_DBG_LEVEL_NOTICE 5           ;
%define JX_DBG_LEVEL_INFO 6             ;
%define JX_DBG_LEVEL_DEBUG 7            ;

JX_DBG_EMERGENCY db '[emergency] in file:', ASCII_CRTL_NULL
JX_DBG_ALERT db '[alert] in file', ASCII_CRTL_NULL
JX_DBG_CRITICAL db '[critical] in file', ASCII_CRTL_NULL
JX_DBG_ERROR db '[error] in file', ASCII_CRTL_NULL
JX_DBG_WARNING db '[warning] in file', ASCII_CRTL_NULL
JX_DBG_NOTICE db '[notice] in file', ASCII_CRTL_NULL
JX_DBG_INFO db '[info] in file', ASCII_CRTL_NULL
JX_DBG_DEBUG db '[debug] in file', ASCII_CRTL_NULL

JX_NAME_LINE db ' on line: ', ASCII_CRTL_NULL
JX_LINE_MESG db ' Message: ', ASCII_CRTL_NULL

%macro debug_print 4
    print_16 %1                         ; Print the type of error.
    print_16 %2                         ; Print the filename.
    print_16 JX_NAME_LINE               ; Print an separator between the file name and line number.
    print_16 %3                         ; Print the line number.
    print_16 JX_LINE_MESG               ; Print separator between the line number and de message.
    print_16 %4                         ; Print the error message.

%endmacro

%endif ; __JORIX_DEBUG_INC_INCLUDED__
%endif ; JORIX_DEBUG_LEVEL
