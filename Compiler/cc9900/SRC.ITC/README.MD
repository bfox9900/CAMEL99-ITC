# Cross-compiler readme
This file contains information on how to use the cross-compiler to rebuild
the Camel99 Forth kernel. This is not needed by the normal user but is here
for the curious. The source code for the cross-compiler is in the Compiler
folder is rather messy but it works.

### Disk System Organization
Version 2.69 uses a new cross-compiler:  FCC99D.EXE
It is in FCC99D.ZIP

The cross-compiler runs on MS DOS. Hey it's retro computing. I used DOSBOX.
In DOS Box create the CC9900 folder tree as it exists in GitHub.
(OLD and WIP folders are not needed)

All paths in the source files are explicitly spelled out in the form:

`CC9900\SRC.ITC\HILEVELY.HSF`

(.HSF files are for Harvard Softworks Forth)

#### Assumed file paths:
```
    c:\forth\                  has FCC99D.exe compiler    
    c:\forth\cc9900\           Project folder
    c:\forth\cc9900\src.itc\   all Camel99 source files for ITC
```    

Therefore unzip FCC99D.ZIP in the \forth\ directory

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


*****************************************************
## Source LOG
### CAMEL99 V2.68G
Broke out CAMEL268.HSF into more separate files and created a "make" file.
FORTHITC.MAK

This is not built with MAKE but rather is just a Forth file that has the
compiler switches and include statements that put together the final kernel.
I find this reduces confusion for building different versions.

The bulk of the of Forth code is contained in the file HILEVEL.HSF which is a
return to how Brad Rodriguez partitioned his versions of Camel Forth.

### Camel V2.68 Notes
July 20, 2021
Found a bug in M+ after working on porting a PI digit calculator.
Thanks to Ed at DxForth who wrote the PI code and spotted my bug.
M+ is also used in >NUMBER and so was a ticking bomb all this time.

#### 9900CODE.HSF  
Removed M+ primitive and replaced with D+ which is a better fit to 9900 CPU.
M+ is now a secondary definition in CAMEL268.HSF

#### CAMEL268.HSF
Changed compiler switch to SLOWER. TRUE to SLOWER compiles more Forth code and
saves ~28 bytes in the kernel. FALSE to SLOWER compiles more code primitives in
the file.

###SOURCE Camel99 V2.67 Source Code Notes
Apr 16, 2021
Since the last release two years ago there have been many improvements to this system.
Improvements to the Video driver to improve overall speed.
Improvements to the compiling speed on the TI-99.
Improvements to many of the library files and some new libraries:

- WORDLIST support.      DSK1.WORDLISTS
- Smaller Assembler      DSK1.ASM9900
- Assembler labels       DSK1.ASMLABELS
- Simpler file access    DSK1.TIFILES  
- Smaller ANS file lib   DSK1.ANSFILES
- Multiple Video pages   DSK1.SCREENS
- Better inlining        DSK1.INLINE   \ inline CODE, variables, constants, USER vars.

#### Better SAMS Memory Managers  
- DSK1.SAMS      \ machine code. fastest access                      
- DSK1.SAMSFTH   \ written in Forth to show how it works
- DSK1.SBLOCKS   \ SAMS virtual memory with two 4K buffers in low RAM.
