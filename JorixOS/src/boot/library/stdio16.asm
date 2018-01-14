;__________________________________________________________________________________________/ stdio16.mac.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 13-01-2018 11:43
;   
;   Description:
;
%ifndef OS_DEVELOPMENT_STDIO16_INCLUDED
%define OS_DEVELOPMENT_STDIO16_INCLUDED

%define STRING_TYPE 0
%define BUFFER_TYPE 1
%define INPUT_BUFFER_TYPE 2
%define OUTPUT_BUFFER_TYPE 3

;________________________________________________________________________________________________________________________/ ϝ exact_string
;   Description:
;   This macro is used to define an exact length string.
;
;   Function Arguments:
;   %1  The label of the string.
;   %2  The
;
%macro string_def 2
%1: db %2, 0
%1_length: equ $-%1
%1_type: db STRING_TYPE
%endmacro

%define string(a) db a, 0


;________________________________________________________________________________________________________________________/ ϝ exact_string
;   Description:
;   This macro is used to define an exact length string.
;
;   Function Arguments:
;   %1  The label of the string.
;   %2  The
;
%macro exact_string_def 4
%1: db %2, 0
%1_length: equ $-%1
%1_type: db STRING_TYPE
%endmacro

%macro exact_string 3
db %1, 0
%1_length: equ $-%1
%1_type: db STRING_TYPE
%endmacro

%macro __def_buffer 3
%1: times %2 db
%1_length: equ $-%1
%1_type: %3
%endmacro

%macro buffer 2
__def_buffer %1, %2, BUFFER_TYPE
%endmacro

%macro input_buffer 2
__def_buffer %1, %2, INPUT_BUFFER_TYPE
%endmacro

%macro output_buffer 2
__def_buffer %1, %2, OUTPUT_BUFFER_TYPE
%endmacro

%macro strlen 1
;TODO   Check if label{_length} exists.
;TODO       If so return the value.
;TODO       Else read bytes until we find a null terminator or reach the maximum length.
%endmacro

%macro bufflen 1
;TODO   Check if the label{_length} exists.
;TODO       If so return the value.
;TODO       Else return 0.
%endmacro

%macro is_a 2
;TODO   Check if the %1_type exists.
;TODO       If so compare to the %2_type.
;TODO       return 0 || 1
%endmacro

%macro get_type 2
;TODO   Check if the %1_type exists.
;TODO       return _type.
%endmacro

%endif ; OS_DEVELOPMENT_STDIO16_INCLUDED
