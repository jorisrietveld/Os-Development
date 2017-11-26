%ifndef MACROS_MAC
%define MACROS_MAC

;
; Print string macro.
; Input: si, Source Index Register
; Output: x
;
%macro print_string 1

%endmacro

;
; Print string macro.
; Input: si, Source Index Register
; Output: x
;
%macro repeat_string 2
    %assign i 0
    %rep    64
    inc     word [table+2*i]
    %assign i i+1
    %endrep
%endmacro

;
; Print string macro.
; Input: di, Data Index Register
; Output: x
;
%macro read_string 1

%endmacro

%endif
