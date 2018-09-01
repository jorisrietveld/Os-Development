<!-- 
  -- Author: Joris Rietveld <jorisrietveld@gmail.com>   
  -- Date: 03-06-2018 02:35    
  -- Licence: GPLv3 - General Public Licence version 3
  -- 
  -- Description:
  --  
  -->

> The bios will load the first configured bootable sector at address 0x7C00 tell NASM to
  use 0x7C00 as the first instruction.
```nasm
    org 0x7C00
```
> Tell nasm that the assembled binary code should be for a 16 bit architecture.
```nasm
  bits 16
```

> Now we need to write the bootable signature at the 510th byte (the signature is 2 bytes (0xAA55).<br>
 ```$``` represents the current line of execution.<br>
 ```$$``` Represents the first line of execution (0x7C00).<br>
 ```($-$$)``` = (currentLine - firstLine)<br>
 It subtracts the first line from the current line which gives you the the amount of bytes currently used.<br>
 The times instruction will do an operation n times: times (n) instruction.<br>
 if the program is 8 bytes the the operation will be: times 510 - (7C08-7C00) db 0.<br>
```nasm
  times 510 - ($-$$) db 0
```

> We are now at the 510th byte of the program, we have only 2 bytes left that will be copied to memory.
 These bytes should contain a signature 0xAA55 to tell the bios this is an bootable sector.
```nasm
 dw 0xAA55               ; Bootable signature.
```
