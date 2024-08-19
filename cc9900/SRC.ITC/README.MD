# Cross-compiler readme
This file contains information on how to use the cross-compiler to rebuild
the Camel99 Forth kernel. This is not needed by the normal user but is here
for the curious. The source code for the cross-compiler is in the Compiler
folder is rather messy but it works.

### Disk System Organization
Version 2.69 uses a new cross-compiler:  FCC99B.EXE
It is in FCC99B.ZIP

The cross-compiler runs on MS DOS. Hey it's retro computing. I used DOSBOX.
In DOS Box create the CC9900 folder tree as it exists in GitHub.
(OLD and WIP folders are not needed)

All paths in the source files are explicitly spelled out in the form:

`CC9900\SRC.ITC\HILEVEL.HSF`

(.HSF files are for Harvard Softworks Forth)


#### Assumed file paths:
```
    c:\forth\                  has XFC99X.exe compiler    
    c:\forth\cc9900\           Project folder
    c:\forth\cc9900\src.itc\   all Camel99 source files for ITC
```    

Therefore unzip XFC99X.ZIP in the \forth\ directory

## Standard Kernel Build V2.69
Loads and runs with normal Editor assembler cartridge. Entry=HEX A000

### To re-build Standard Kernel
set the compiler switches as shown below in FORTHITC.MAK

 ```
 TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
 FALSE VALUE SLOWER       \ TRUE saves 28 bytes
 FALSE VALUE HASHING      \ Not working yet
 TRUE \ true= standard kernel ;  false=non-standard kernel
 [IF]
     A000 VALUE KERNORG
     2000 VALUE HEAPORG
 [ELSE]
      6000 VALUE KERNORG  \ the specific alternate load address to use
      2000 VALUE HEAPORG  \ initial HEAP address when kernel boots
 [THEN]
```

At the DOS prompt type:    
```
XFC99X  fload cc9900\src.itc\forthitc.mak
```
Enjoy the prompts scrolling by.
This will create a PROGRAM file called CAMEL99

### SuperCart Kernel Build
SuperCart Kernel is a binary image that loads and runs with Editor
Assembler Super Cartridge that has 8K RAM installed. This is puts
Camel99 in the cartridge memory space and gives you access to the
"entire" 32K of RAM. :)

*The SUPERCART kernel is not compatible with DSK1.SAVESYS library file. (YET)

ONLY one flag needs to change in FORTHITC.MAK to build Camel99 for SuperCart.
```
TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
FALSE VALUE SLOWER       \ TRUE saves 28 bytes
FALSE VALUE HASHING      \ Not working yet

FALSE  \ **set to false for SuperCart kernel**
[IF]
    A000 VALUE KERNORG
    2000 VALUE HEAPORG
[ELSE]
     6000 VALUE KERNORG  \ the specific alternate load address to use
     2000 VALUE HEAPORG  \ initial HEAP address when kernel boots
[THEN]
```

At the DOS prompt type:    
```
XFC99Y fload cc9900\src.itc\forthitc.mak
```
This will create a PROGRAM file call CAML99SC


