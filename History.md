## Change History
### Apr 15 2018:
- Overall speed up by writing HERE ALLOT  >DIGIT and HOLD as code words. This improves compilation speeds and number printing is 50% faster.

### Apr 17 2018
- Found a bug where the new faster scroll obliterated first two sprite records when scrolling. Repaired.

### May 9 2018
- Committed change in 2.0.13 which fixes an old bug that caused difference entry address for DOVAR between cross-compiler varibles and TI-99 created variables. Homemade cross-compilers... what are you gonna do?

### Jun 3 2018 V2.0.15
- SND! is now a code word. Speeds up writes to the sound chip by 75% for a 2 byte penalty.(more important with background players)
- ?ABORT is smaller because it use SOURCE instead of HERE COUNT. (totally missed that)
- ">BODY" was a wrapper on 2+. Now it is a code word synonym for 2+.

### Jun 8 2018 V2.0.16
- Oops, Making a faster >BODY broke the multi-tasker. Somehow changing R14 ?? Removed >BODY from KERNEL.
It now loads in the DSK.START file as a library file: TOBODY.F

### Jun 21, 2018 V2.0.18
- Re-wrote looping primitives in Structured Assembler. Found some wasted instructions and speedups.
- Found size savings in FILESYSD.F
- Kernel now 40 bytes smaller.
- Change to EOF to now take a file handle.
- Re-wrote demo programs
- Fixed bug in file handle server and RELEASE handle routine
- New manual version 0.99 needs final edit review.

### Jul 10, 2018 V2.0.19
- Internal test version

### Aug 4, 2018 V2.0.20
- Kernel is 16 bytes smaller
- Removed word INCLD from kernel and put code in body of INCLUDED
- Change INIT code to use structured assembler loop
- Comment improvements
- Move DATA stack reset in COLD word to just before QUIT. This fixed the first error bug.
 (First bad word entered at console gave "empty stack" error)
- Removed SPRITE support word DXY from KERNEL, moved to DIRSPRIT (direct sprite control) as a machine code word.
- Added SEE.F to DSK1 which is a Forth decompiler.
### Aug 23, 2018 V2.0.21
- Moved @ and DROP primitives into 16 bit RAM for small speed improvement.
- Put MOVE in the kernel which is used by PLACE. This makes PLACE a little slower but means it can be used in more dynamic memory environments (PLaying with lists)
- Fixed silly bug with FUSE
- changes to MOTION.F, a simple sprite motion control wordset (not automotion)
- Uploaded DEMO/ELIZA/ELIZA2.FTH a preliminary verion of the classic lisp psychotherapist (bugs)
- fixed bug in POS$ (STRINGS.FTH)

### Sept 1, 2018 V2.0.22
- V2.0.22 now can print text and numbers to VDP screen from any task
- Changes to Video i/o primitives so they are multi-tasking friendly. ASM code now uses USER variable indexed addressing so that variables VROW VCOL C/L and OUT are unique for every task.
- HOLD reverted back to Forth version for multi-tasking
- Added TPAD USER VARIABLE which hold the offset of PAD from HERE. By setting TPAD to bigger number for other tasks, each task gets a pad and HOLD buffer in unallocated dictionary memory.

### Nov 13, 2018 V2.1.E
- Floored division is now the default per ANS/ISO standard.
  Symmetrical division is set using the FLOOR variable: FLOOR OFF, FLOOR ON
  Due to the slow speed of the 9900 CPU it is coded in Forth Assembler.
  The code is a re-work of code, used by permission, from FB-Forth by
  Lee Stewart. ( fbforth.stewkitt.com/ )
- Forth primitives separated into 2 files: 9900FAS2.HSF, TI99PRIMS.HSF
- RSTPAB (reset PAB) added to QUIT for stability when using file system.
- Improved ?TERMINAL so it waits for key release after key press.

### Nov 30, 2018 V2.1.F
- *COMPILER CHANGE: To handle ITC and DTC versions the cross-compiler "word creators"
  are kept in separate files and are included in the Forth system source code as required.
  Documentation is forth coming.  See compiler/ITCTYPES.HSF  and compiler/DTCTYPE.HSF

- Source file CAMEL99F.HSF now has a compiler switch, SMALLER, that uses
  Forth words to save space when set to TRUE and more CODE words if SMALLER
  is set to FALSE. SMALLER saves ~46 bytes, but runs a little slower.

- Addition of CALLCHAR and LOADSAVE libraries allows compiling FONT
  information into binary font files that load into VDP ram in 1 second.
- Font file source code examples are in FONTS folder. Compiled binary versions are in DSK3.
- Addition of a direct threaded code (DTC) version of the system that runs about 10% faster.
  *note* CREATE DOES> is not functional in the DTC version at this time.

### Nov 30, 2018 V2.1.G
- Version G corrects a long-time bug in the interpreter that reported
"empty stack" under some conditions erroneously (CAMELG2.HSF)
- Compiler switch name has been changed to USEFORTH (previously SMALLER) because
sometimes Forth is smaller and sometimes Assembler code is smaller.
- Version G has a code word for DIGIT? to improved compile times
- The word ?SIGN is now PRIVATE, no visible in the dictionary to save space
- The word >NUMBER has been changed slighly from the original CAMEL FORTH that speeds
it for the 9900 cpu.
- The ELAPSE.FTH program has been significantly improved for accuracy and the
code size has been reduced.
- A file based BLOCK system is available as a library: /LIB.ITC/BLOCKS.FTH
These blocks are compatible with FBFORTH and Turbo Forth allowing the developer
read programs from these other Forth systems.  Compiling this code will not be
possible without writing a "translation harness" however for simple programs
this is not too difficult.
- A simple demo of BLOCK usage is file LINEDIT80.FTH for use with 80col displays
or the TTY based kernel CAMEL99T
- data structures per Forth 2012 are now supported in file STRUC12.FTH. A simple
example is part of the file. (remove or comment out if you use the file)
- ACCEPT has been changed passing backspace cursor control to EMIT. (see below)
- EMIT has been changed to handle newline and backspace characters
- (EMIT) and (CR) i/o primitives can be compiled as Forth or CODE
(controlled by USEFORTH )

### CAMEL99T (tty)
- Version CAMEL99T is built to use RS232/1 as the primary console. It has been
tested with Tera Term, Hyper-terminal and PUTTY under windows 10. Terminal
configuration is 9600,8,n,1, hardware handshake.
- A word VTYPE ( $addr len VDPaddr -- ) is part of the CAMEL99T to allow
simple printing to the VDP screen at a screen address. (no protection!)
- Library file call XONXOFF.FTH vectors EMIT to provide XON/XOFF protocol
- File VT100 can be included to provide cursor control for a VT100 terminal.

### April 23 2018
- CAMEL99.FTH source is a cleaned up code using mostly Forth to create the FORTH
compiler
- CAMEL99G has a few cosmetic changes in the source but use DSRLNKA and FILESYSX
- DSRLNKA is a corrected version of the DSR link program and it also takes a
filename string VDP address from the top of stack as an input argument.
- FILESYSX gives us a faster FILEOP word because it passes the argument to DSRLINK
on the top of the stack and DSRLNKA now does the GPLstatus clearing and reading
in Assembler for us.
- THEFLYDEMO is demonstrates how to create BASS frequencies in the TMS9919
sound chip channel 4 using NOISE MODE 3 and controlling the frequency with
channel 3.  The BUZZ of the fly is created this way.

### Nov 28, 2019  V2.5
Indirect Threaded Version
- Settled on one build of CAMEL99 Forth. All variations are removed.
- 25% speed up of CREATE DOES> structures by using BRANCH & LINK instruction
- Fixed DSK1.ANSFILES file handle bug. Errors did not release current file handle.
- Improved VDP screen driver using 1+@ code word
- Improved DSK1.VALUES. Faster TO and +TO
- Cleaned up LIB.ITC. TI99 versions are in DSK1.
- Added DSK1.TRAILING. (-TRAILING -LEADING TRIM)
- Added DSK1.HEXNUMBER. H# is a prefix word to interpret numbers as radix 16.
- DSK1.TOOLS now includes VDUMP for VDP ram and SDUMP code for SAMS card.
  (HEX and BINARY numbers alway print unsigned after tools are loaded.)
- DSK1.CODEMACROS provides native 9900 indexed addressing arrays.
- DSK1.VTYPE improved VTYPE updates VCOL. AT" ( x,y) placing text.
- DSK1.AUTOMOTION provides Automatic sprite motion like Extended BASIC









