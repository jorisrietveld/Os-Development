;
; Author: Joris Rietveld - <jorisrietveld@gmail.com>
; Github: <https://github.com/jorisrietveld>
; Date created: 06-09-2018 17:42
; Licence: GPLv3 - General Public Licence version 3 <https://www.gnu.org/licenses/gpl-3.0.txt>
;
; Description:
;

%ifndef __GLOBAL_INC_INCLUDED__
%define __GLOBAL_INC_INCLUDED__

%define IMAGE_PROTECTED_MODE_BASE 0x100000
%define IMAGE_REAL_MODE_BASE 0x3000

KernelNameAsm db "KRNL_ASMBIN"
KernelNameC db "KRNL_C  BIN"
KernelNameCpp db "KRNL_CPPBIN"

ImageSize db 0x00


%endif