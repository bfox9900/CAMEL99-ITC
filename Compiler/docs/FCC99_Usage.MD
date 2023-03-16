# Cross-compiler Usage 

This file contains information on how to use the cross-compiler to rebuild
the Camel99 Forth kernel. This is not needed by the normal user but is here
for the curious. The source code for the cross-compiler is in the src
folder is rather messy but it works.

### Disk System Organization
The newest version of the cross-compiler is FCC99D.exe.
It is in the FCC99D.ZIP file.

The cross-compiler runs on MS DOS. Hey it's retro computing. I used DOSBOX.
In DOS Box create the CC9900 folder tree as it exists in GitHub.
(OLD and WIP folders are not needed)

All paths in the source files are explicitly spelled out in the form:
(.HSF files are for Harvard Softworks Forth)

          CC9900\SRC.ITC\HILEVEL.HSF

Therefore unzip XFC99X.ZIP in a folder below CC9900.
Example:
c:\forth             has XFC99X.exe
c:\forth\cc9900      contains the source files

## Standard Kernel Build V2.69
Loads and runs with normal Editor assembler cartridge. Entry=HEX A000

### To re-build Standard Kernel
set the compiler switches as shown below in FORTHITC.MAK
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

At the DOS prompt type:   FCC99D  fload cc9900\src.itc\forthitc.mak

### SuperCart Kernel Build
This script makes a version of Camel99 Forth that loads and runs with Editor Assembler Super Cartridge that has an 8K RAM chip installed.

Entry=HEX 6000
*This kernel does not work with DSK1.SAVESYS library file.
 Rather use the DSK1.SUPERSAVE library to make program images with the Supercart Forth. 

*ONLY one flag needs to change in FORTHITC.MAK as shown below:

```
    TRUE  VALUE ITC          \ used to prevent directly compiling HILEVEL.HSF
    FALSE VALUE SLOWER       \ TRUE saves 28 bytes
    FALSE VALUE HASHING      \ Not working yet

    FALSE  \ **Change this one to change the kernel**
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
C:\> FCC99D fload cc9900\src.itc\forthitc.mak
```

*****************************************************
## Kernel Version LOG

### CAMEL99 V2.69 
Removed TICKS. Replaced with MS which is now set to 1MS resolution. 
This may be longer while multi-tasking. 

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
M+ is also used in >NUMBER and so was a ticking bomb all this time.

#### 9900CODE.HSF  
Removed M+ primitive and replaced with D+ which is a better fit to 9900 CPU.
M+ is now a secondary definition in CAMEL268.HSF

#### CAMEL268.HSF
Changed compiler switch to SLOWER. TRUE to SLOWER compiles more Forth code and
saves 30 bytes in the kernel. FALSE to SLOWER compiles more code primitives in
the file.

###SOURCE Camel99 V2.67 Source Code Notes
Apr 16, 2021
Since the last release two years ago there have been many improvements to this system.
Improvements to the Video driver to improve overall speed.
Improvements to the compiling speed on the TI-99.
Improvements to many of the library files and some new libraries:

WORDLIST support.      DSK1.WORDLISTS
Smaller Assembler      DSK1.ASM9900
Assembler labels       DSK1.ASMLABELS
Simpler TI BASIC files DSK1.TIFILES  
Smaller ANS file lib   DSK1.ANSFILES
Multiple Video pages   DSK1.SCREENS
Better inlining        DSK1.INLINE   \ inlines CODE, variables, constants
                                     \ and USER vars.

Better SAMS memory    DSK1.SAMS      \ machine code. fastest access
                      DSK1.SAMSFTH   \ written in Forth for understanding
                      DSK1.SBLOCKS   \ SAMS virtual memory. Uses BLOCK
