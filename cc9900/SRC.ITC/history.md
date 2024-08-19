# Camel99 Forth Version History

### Camel99 V2.7*  2024 
In this release I opted to reduce the size of the console driver by using more 
Forth and less code. It's a bit slower but this saved over 100 bytes in the kernel. On a tiny machine like TI-99 this seems more important. 

*KEY? changed to be compliant with ANS Forth. It only returns a flag.
KEY was therefore changed to test for the flag and read the key buffer at >8375.
This changed was need for RKEY as well. 

##### JIT Compiler 
Not a full fledged JIT compiler but it compiles the following to native code:
- code words 
- variables
- constants 
- literals
- if/else/then
- BEGIN WHILE REPEAT UNTIL AGAIN
- DO LOOP 

Speed improvement on the Byte Magazine Sieve program is 2.4 times. 
This is because the calculation loop is all Forth primitives.


## CAMEL99 V2.68G
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

### Camel99 V2.67 Source Code Notes
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
- Better inlining        DSK1.INLINE 
  - now inlines CODE, variables, constants, USER vars

#### Better SAMS Memory Managers  
- DSK1.SAMS      \ machine code. fastest access                      
- DSK1.SAMSFTH   \ written in Forth to show how it works
- DSK1.SBLOCKS   \ SAMS virtual memory with two 4K buffers in low RAM.
