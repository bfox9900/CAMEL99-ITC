# CAMEL99-V2
CAMEL99 V2 finally has TI file access.  The binary program is in folder DSK1 and is called CAMEL2.

The system boots when you load the file called DSK1.CAMEL2 with the Editor/Assembler cartridge. When CAMEL2 starts it looks for a file called DSK1.START. If found it loads that file as source code.  You put any new definitions in the START file that you want. Currently there are bugs with nested INCLUDEs so don't try that.

## Making TI Source Code Files
A simple way to create TI Files it to open the TI Editor (Menu Option 1) then open the editor. Using the the Classic99 emulator on your PC you can paste text into the TI editor window and then save the file in the default DV80 format. (DV80 means text file, variable records, 80 bytes per record).  Since the maximum record size in these files is 80 bytes, your source code lines cannot exceed 80 characters.

With your file correctly saved to DSK1 you can type S" DSK1.MYFILE" INCLUDED in the CAMEL99 console and the file will be loaded as source code.


