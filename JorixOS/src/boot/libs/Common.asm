;________________________________________________________________________________________________________________________/ Common.asm
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 03-01-2018 01:02
;   
;   Description:
;   This file contains some global constants and variables.

%ifndef __COMMON_ASM_INCLUDED__
%define __COMMON_ASM_INCLUDED__

%define IMAGE_PROTECTED_MODE_BASE 0x100000
%define IMAGE_REAL_MODE_BASE 0x3000

ImageName   db  "KERNEL  SYS"
ImageSize   db  0

%endif ; __COMMON_ASM_INCLUDED__

