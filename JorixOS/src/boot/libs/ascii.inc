;__________________________________________________________________________________________/ ascii.inc
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 06-01-2018 07:45
;   
;   Description:
;   This file defines easy to remember names for ascii control codes and characters.
;
%ifndef __ASCII_INC_INCLUDED__
%define __ASCII_INC_INCLUDED__

%define ASCII_CRTL_NULL  0x00            ; Null character.
%define ASCII_CRTL_SOH  0x01            ; Start Of Heading character.
%define ASCII_CRTL_STX  0x02            ; Start Of Text character.
%define ASCII_CRTL_ETX  0x03            ; End Of Text character.
%define ASCII_CRTL_EOT  0x04            ; End Of Transmission character.
%define ASCII_CRTL_ENQ  0x05            ; Enquiry character.
%define ASCII_CRTL_ACK  0x06            ; Acknowledgement character.
%define ASCII_CRTL_BEL  0x07            ; Bell character.
%define ASCII_CRTL_BS   0x08            ; Backspace character.
%define ASCII_CRTL_HT   0x09            ; Horizontal Tab character.
%define ASCII_CRTL_LF   0x0A            ; Line Feed character.
%define ASCII_CRTL_VT   0x0B            ; Vertical Tab character.
%define ASCII_CRTL_FF   0x0C            ; Form Feed character.
%define ASCII_CRTL_CR   0x0D            ; Carriage Return character.
%define ASCII_CRTL_SO   0x0E            ; Shift Out character.
%define ASCII_CRTL_SI   0x0F            ; Shift In character.
%define ASCII_CRTL_DLE  0x10            ; Data Link Escape character.
%define ASCII_CRTL_DC1  0x11            ; Device Control 1 character.
%define ASCII_CRTL_DC2  0x12            ; Device Control 2 character.
%define ASCII_CRTL_DC3  0x13            ; Device Control 3 character.
%define ASCII_CRTL_DC4  0x14            ; Device Control 4 character.
%define ASCII_CRTL_NAK  0x15            ; Negative Acknowledgement character.
%define ASCII_CRTL_STN  0x16            ; Synchronous Idle character.
%define ASCII_CRTL_ETB  0x17            ; End of Transmission Block character.
%define ASCII_CRTL_CAN  0x18            ; Cancel character.
%define ASCII_CRTL_EM   0x19            ; End of Transmission Block character.
%define ASCII_CRTL_SUB  0x1A            ; Cancel character.
%define ASCII_CRTL_ESC  0x1B            ; End of Medium character.
%define ASCII_CRTL_FS   0x1C            ; Substitute character.
%define ASCII_CRTL_GS   0x1D            ; Escape character.
%define ASCII_CRTL_RS   0x1E            ; File Separator character.
%define ASCII_CRTL_US   0x1F            ; Group Separator character.
%define ASCII_CRTL_DEL  0x7F            ; Record Separator character.

; Shorthand for end of line
%define NEWLN 0x0A0D00

%endif ; __ASCII_INC_INCLUDED__
