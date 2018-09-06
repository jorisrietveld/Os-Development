;__________________________________________________________________________________________/ types.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 07-06-2018 13:34
;   
;   Description:
;   This file defines variable types macros for better readability.
;
[bits 16]

%ifndef __TYPE_INC_INCLUDED__
%define __TYPE_INC_INCLUDED__

%include 'libs/ascii.inc'

;_________________________________________________________________________________________________________________________/ ϝ string
;   Description:
;   This macro can be used to easily create new null terminated strings.
;
;   Function Arguments:
;   1       The name (label) of the variable, used to access it later.
;   2       The contents of the string.
;
%macro string 2
    %1 db %2, ASCII_CRTL_CR, ASCII_CRTL_LF, ASCII_CRTL_NULL
%endmacro

%endif ; __TYPE_INC_INCLUDED__
