# CAMEL99 for TI-99 V2.5

### ABOUT CAMEL99 V2.5
------------------------
CAMEL99 Forth was built as an educational exercise to learn how to cross-compile Forth to a different CPU using an existing Forth system. It has become a functional ISO/Forth system for the TI-99 computer that implements all of the CORE wordset, much of the EXTENDED wordset.

Rather than starting from scratch CAMEL99 uses CAMEL Forth by Dr. Brad Rodriguez for the hi-level Forth code. This has been "tweeked" and dare I say improved a little to better fit the very slow TI-99 computer. (More things written in Assembler was the answer)

The low level primitives are written in Forth Assembler. The file 9900FAS2.HSF also contains the low level drivers for TI-99 Keyboard and Video display I/O. The final console interfaces are written in Forth including the screen scrolling code, just to demonstrate how it can be done in hi-level Forth.

In CAMEL99 Version 2 we squeezed enough disk support into the 8K kernel to have the word INCLUDED in the system.  This let's the system compile Forth code from disk which means it can extend itself.

### Made Friendly for BASIC Programmers
Users of TI BASIC who want to explore Forth might also find this system useful. With that in mind it has a string package that provides many of the features of BASIC including the use of a string stack and automated stack management. It also has an INPUT statement for strings and numbers.  You will also find the TI BASIC graphics functions are emulated in the library file called GRAFIX.  The instruction manual has been written to compare BASIC and Forth and there are example programs where the BASIC code is side by side with Forth for faster understanding for those new to Forth.

You can load all the "training wheels" with one command: INCLUDE DSK1.BASICHLP
... and the files compile into the system. This gives the BASIC programmer most of TI BASIC'S features, but it still requires learning Forth's way of thinking to use it.  

### Changes from V1
- CAMEL99 V2 finally has TI file access and numerous enhancements that improved the speed/size tradeoff.
- The binary program is in folder DSK1 and is called CAMEL99
- The library files exist in DSK1 as TI-99 DV80 TEXT files
- Folder LIB.ITC contains the same files and more in PC format.


### How it was made
- CAMEL99 begins with a TMS9900 Cross-Assembler written in HsForth, an MS DOS Forth system written in the 1990s. (The cross-compiler is XFC99.EXE)

- With the cross-assembler we define the primitive operations in the file 9900FAST.HSF.

- The Cross-Assembler is combined with a Cross-compiler, which gives us the tools to create the Forth dictionary, a linked list of structures in the TARGET memory image. This lets us give each primitive a "header" (name) in the dictionary with pointers to the code that they will run.

- The file CAMEL99.HSF uses the assembler primitives to create the high level Forth words that let us build the TARGET COMPILER.

- As each piece is added to the TARGET system less of the Cross-compiler is used. It's truly an excerise in boot-strapping.

### For the Forth Tech
CAMEL99 is an indirect threaded Forth with the top of stack cached in Register 4 of the CPU. This has shown to give similar performance to the TI-99 system Turbo Forth, which is the benchmark system for speed on TI-99 but CAMEL99 uses less assembler code in the overall system. In comparison to legacy implementations like Fig-Forth CAMEL99 is about 20% faster in high-level Forth operations.

The system boots when you load the TI-99 binary program file called DSK1.CAMEL99 with the Editor/Assembler cartridge. When CAMEL99 starts, it looks for a file called DSK1.START. If found it loads that file as source code. Currently START "INCLUDES"  the file DSK1.SYSTEM which compiles missing CORE Forth words that could not fit in the 8K kernel.

( INCLUDE, CELLS , CELL+ , CHAR+ , >BODY, CHAR , [CHAR] )

NOTE: Nested INCLUDE files are now working in V2.0.4

## Windows TI-99 Emulator
You can run this code on CLASSIC99, an excellent emulator, that runs on Windows. CLASSIC99 is available here:

http://www.harmlesslion.com/cgi-bin/onesoft.cgi?1

Other emulators are available but have not been tested by the author.

### Starting CAMEL99 Forth
Start the TI-99 computer with the Editor/Assembler cartridge.  The folder DSK1 must be present on DSK1 of your computer or emulator.
Select the run program file option from the menu and enter "DSK1.CAMEL99"

## Loading Source Code Files
Wait for the SYSTEM file to compile.
At the console type: INCLUDE DSK1.TOOLS -or- S" DSK1.TOOLS" INCLUDED

When Forth returns with "ok" type "WORDS" and press enter and you will see all the words in the Forth dictionary.

Press FNCT 4 (BREAK) to stop the display at any time.

It's that easy.

## Making TI Source Code Files
ALL the TI-99 source code files for CAMEL99 must be in TI-99 DV80 format. DV80 means a "DISPLAY" (text) file, variable records, with 80 bytes per record.  Since the maximum record size in these files is 80 bytes, your source code lines cannot exceed 80 characters.

(COPIES OF THE LIBRARY SOURCE FILES FILES ARE IN /LIB.ITC AS TEXT FILES)

A simple way to create TI Files on a PC is to open the TI Editor (Menu Option 1) and start the editor (Menu Option 1).
Using the the Classic99 emulator on your PC you can paste text into the TI editor window and then save the file in the default DV80 format by following the on screen prompts. It's a quaint old fashioned editor but it works.  Intructions on how to use the editor are in the manual here:

https://github.com/bfox9900/CAMEL99-V2/tree/master/DOCS

With your file correctly saved to DSK1 you can type S" DSK1.MYFILE" INCLUDED in the CAMEL99 console and the file will be loaded as source code. The current version of CAMEL99 V2 takes almost all of the 8K Binary space that is the current maximum program size generated by XFCC99 cross-compiler. This means that all additions to the system must be loaded as source code at this time.

Source code will load/compile at the blazing speed of about 14 lines per second. :-)

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


### Known BUG (Not a bug)
- When INCLUDE is used for a file on a disk other than DSK1, the library files will try to load from that same disk.  Investigating our FILESYSX for the problem.
- Resolved. It was a configuration error in the Classic99 Emulator. 









