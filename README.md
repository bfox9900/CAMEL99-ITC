# CAMEL99-V2.0.8

### Apr 15 2018:
Overall speed up by writing HERE ALLOT  >DIGIT and HOLD as code words. The improves compilation speeds and number printing is 50% faster.

### Overview
CAMEL99 V2 finally has TI file access.  The binary program is in folder DSK1 and is called CAMEL2.
All of the loadable source files have a .F extension except the START file which is unique.

The system boots when you load the TI-99 binary program file called DSK1.CAMEL2 with the Editor/Assembler cartridge. When CAMEL2 starts, it looks for a file called DSK1.START. If found it loads that file as source code.  You can put any new Forth definitions in the START file that you want. Currently START "INCLUDES" the following Forth words into the dictionary:
     INCLUDE, CELLS, CELL+, CHAR+, CHAR , [CHAR]

NOTE: Nested INCLUDE files are now working in V2.0.4

## Loading Source Code Files
At the console TYPE INCLUDE DSK1.TOOLS.F  -or- S" DSK1.TOOLS.F" INCLUDED

When Forth returns to you type WORDS and press enter and you will see all the words in the Forth dictionary.  

Press FNCT 4 (BREAK) to stop the display.

It's that easy.

## Making TI Source Code Files
ALL source code files for CAMEL99 must be in DV80 format. DV80 means a "DISPLAY" (text) file, variable records, with 80 bytes per record.  Since the maximum record size in these files is 80 bytes, your source code lines cannot exceed 80 characters.

A simple way to create TI Files on a PC is to open the TI Editor (Menu Option 1) and start the editor (Menu Option 1). 
Using the the Classic99 emulator on your PC you can paste text into the TI editor window and then save the file in the default DV80 format by following the on screen prompts. It's a quaint old fashioned editor but it works.

With your file correctly saved to DSK1 you can type S" DSK1.MYFILE" INCLUDED in the CAMEL99 console and the file will be loaded as source code. The current version of CAMEL99 V2 takes almost all of the 8K Binary space that is the current maximum program size generated by my TI-99 cross-compiler. This means that all additions to the system must be loaded as source code at this time. 

Source code will load/compile at the blazing speed of about 14 lines per second. :-)

### Future Developments
Now that we have file access the TI-99 file system a binary save/load mechanism is on the hot list of things to add. This would allow you to build a program from source code and then save it off as a Binary file and then load that "system snapshot" back into the system without re-compiling.
