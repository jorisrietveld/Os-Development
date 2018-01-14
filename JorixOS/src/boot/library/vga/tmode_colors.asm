;__________________________________________________________________________________________/ tmode_colors.asm    
;   Author: Joris Rietveld  <jorisrietveld@gmail.com>
;   Created: 14-01-2018 13:30
;   
;   Description:
;
%ifndef BOOT_LIBRARY_VGA_TMODE_COLORS_INCLUDED
%define BOOT_LIBRARY_VGA_TMODE_COLORS_INCLUDED

 ; VGA Text Mode 7 colors.
%define VGA_BLACK           0
%define VGA_BLUE            1
%define VGA_GREEN           2
%define VGA_CYAN            3
%define VGA_RED             4
%define VGA_MAGENTA         5
%define VGA_BROWN           6
%define VGA_GRAY            8
%define VGA_WHITE           F

 ; VGA Text Mode 7 light colors.
%define VGA_LIGHT_GRAY      7
%define VGA_LIGHT_BLUE      9
%define VGA_LIGHT_GREEN     A
%define VGA_LIGHT_CYAN      B
%define VGA_LIGHT_RED       C
%define VGA_LiGHT_MAGENTA   D
%define VGA_LIGHT_BROWN     E


%endif ;  BOOT_LIBRARY_VGA_TMODE_COLORS_INCLUDED
