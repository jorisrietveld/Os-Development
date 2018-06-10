;__________________________________________________________________________________________/ common.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 07-06-2018 18:29
;   
;   Description:
;   An collection of commonly used libraries. Most libraries define "Human Friendly" names
;   for hexadecimal addresses, function arguments, characters, etc.
;
%ifndef __COMM_INC_INCLUDED__
%define __COMM_INC_INCLUDED__

%include 'libs/ascii.inc'
%include 'libs/bios.inc'
%include 'libs/types.inc'
%include 'libs/ps2.inc'
%include 'libs/jorix_debug.inc'

%endif ; __COMM_INC_INCLUDED__
