# Source LOG

### Camel V2.68 Notes
July 20, 2021
Found a bug in M+ after working on porting a PI digit calculator.
M+ is also used in >NUMBER and so was a ticking bomb all this time.

#### 9900CODE.HSF  
Removed M+ primitive and replaced with D+ which is a better fit to 9900 CPU.

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
