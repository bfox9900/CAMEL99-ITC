# CAMEL99 for TI-99 V2.1.E

### ABOUT CAMEL99 V2
---------------------
CAMEL99 Forth has been built as an educational tool for those who are interested in how you could cross-compile Forth to a different CPU using an existing Forth system. Rather than starting from scratch it uses CAMEL Forth by Dr. Brad Rodriguez for the hi-level Forth code. 
This has been "tweeked" and dare I say improved a little to better fit the very slow TI-99 computer. (More things written in Assembler was the answer)

The low level primitives are written in Forth Assembler. The file 9900FAST.HSF also contains the low level drivers for TI-99 Keyboard and Video display I/O. The final console interfaces are written in Forth including the screen scrolling code, just to demonstrate how it can be done in hi-level Forth. 

In CAMEL99 Version 2 we squeezed enough disk support into the 8K kernel to have the word INCLUDED in the system.  This let's the system compile Forth code from disk which means it can extend itself.

### Made Friendly for BASIC Programmers
Users of TI BASIC who want to explore Forth might also find this system useful. With that in mind it has a string package that provides many of the features of BASIC including the use of a string stack and automated stack management. It also has an INPUT statement for strings and numbers.  You will also find the TI BASIC graphics functions are emulated in the library file called GRAFIX.  The instruction manual has been written to compare BASIC and Forth and there are example programs where the BASIC code is side by side with Forth for faster understanding for those new to Forth.  

You can load all the "training wheels" with one command: INCLUDE DSK1.BASICHLP
... and the files compile into the system. This gives the BASIC programmer most of TI BASIC'S features, but it still requires learning Forth's way of thinking to use it.  

(Future: Include a more TI-BASIC-like file control wordset. ANS Forth file wordset is too complicated)

### Changes from V1
- CAMEL99 V2 finally has TI file access and numerous enhancements that improved the speed/size tradeoff. 
- The binary program is in folder DSK1 and is called CAMEL99. 
- All TI-99 FORMAT source files have no extension.
- The same files can be found in LIB.TI with a .FTH extension.

### How it was made
- CAMEL99 begins with a TMS9900 Cross-Assembler written in HsForth, an MS DOS Forth system written in the 1990s.
  (The cross-compiler is XFC99.EXE)

- With the cross-assembler we define the primitive operations in the file 9900FAST.HSF. 

- The Cross-Assembler is combined with a Cross-compiler, which gives us the tools to create the Forth dictionary, a linked list of structures in the TARGET memory image. This lets us give each primitive a "header" (name) in the dictionary with pointers to the code that they will run. 

- The file CAMEL99.HSF uses the assembler primitives to create the high level Forth words that let us build the TARGET COMPILER. 

- As each piece is added to the TARGET system less of the Cross-compiler is used. It's truly an excerise in boot-strapping.

### For the Forth Tech
CAMEL99 is an indirect threaded Forth with the top of stack cached in Register 4 of the CPU. This has shown to give similar performance to the TI-99 system Turbo Forth, which is the benchmark system for speed on TI-99 but CAMEL99 uses less assembler code in the overall system. In comparison to legacy implementations like Fig-Forth CAMEL99 is about 20% faster in high-level Forth operations.

The system boots when you load the TI-99 binary program file called DSK1.CAMEL99 with the Editor/Assembler cartridge. When CAMEL99 starts, it looks for a file called DSK1.START. If found it loads that file as source code.  You can put any new Forth definitions in the START file that you want. Currently START "INCLUDES" the following Forth words into the dictionary:
     INCLUDE, CELLS , CELL+ , CHAR+ , CHAR , [CHAR]

NOTE: Nested INCLUDE files are now working in V2.0.4

## Windows TI-99 Emulator
You can run this code on CLASSIC99, an excellent emulator, that runs on Windows. CLASSIC99 is available here:

http://www.harmlesslion.com/cgi-bin/onesoft.cgi?1

Other emulators are available but have not been tested by the author.

### Starting CAMEL99 Forth
Start the TI-99 computer with the Editor/Assembler cartridge.  The folder DSK1 must be present on DSK1 of your computer or emulator.
Select the run program file option from the menu and enter "DSK1.CAMEL99" 

## Loading Source Code Files
At the console type: INCLUDE DSK1.TOOLS.F  -or- S" DSK1.TOOLS.F" INCLUDED

When Forth returns to you type "WORDS" and press enter and you will see all the words in the Forth dictionary.  

Press FNCT 4 (BREAK) to stop the display.

It's that easy.

## Making TI Source Code Files
ALL the TI-99 source code files for CAMEL99 must be in TI-99 DV80 format. DV80 means a "DISPLAY" (text) file, variable records, with 80 bytes per record.  Since the maximum record size in these files is 80 bytes, your source code lines cannot exceed 80 characters.

(COPIES OF THE LIBRARY SOURCE FILES FILES ARE IN /LIB.TI AS TEXT FILES)

A simple way to create TI Files on a PC is to open the TI Editor (Menu Option 1) and start the editor (Menu Option 1). 
Using the the Classic99 emulator on your PC you can paste text into the TI editor window and then save the file in the default DV80 format by following the on screen prompts. It's a quaint old fashioned editor but it works.

With your file correctly saved to DSK1 you can type S" DSK1.MYFILE" INCLUDED in the CAMEL99 console and the file will be loaded as source code. The current version of CAMEL99 V2 takes almost all of the 8K Binary space that is the current maximum program size generated by my TI-99 cross-compiler. This means that all additions to the system must be loaded as source code at this time. 

Source code will load/compile at the blazing speed of about 14 lines per second. :-)

### Future Developments
Now that we have file access the TI-99 file system, a binary save/load mechanism is on the hot list of things to add. This would allow you to build a program from source code and then save it off as a Binary file and then load that "system snapshot" back into the system without re-compiling.


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
  Due to the slow speed of the 9900 CPU it is coded in Forth Assembler.
  The code is a re-work of code, used by permission from FB-Forth by
  Lee Stewart.
- Separated Forth primitives and TI-99 I/O primitives into 2 files.
- RSTPAB added to QUIT for stability when using file system.
- Improved ?TERMINAL so it waits for key release after key press.
