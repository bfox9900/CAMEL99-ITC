# TI-99 Library Files

These files have no extension because the TI-99 file system uses the '.' character to delimit device names and parameters. These files are all in the default format for assembler source code on the TI-99. This format is described as DISPLAY, VARIABLE 80 or DV80 as a short form.

DV80 means ASCII text characters are the only characters in the file and the records are 80 bytes long. They are edited with the Editor assembler Editor program (EDIT1) or the third party 80 column editor called EDIT80.

### Usage
The are the text files in PC format that you can edit. To use them on real TI-99
hardware they must be converted to TI-99 FILES. This can be done by starting
the TI Editor in the Editor/Assembler cartridge on the Classic99 emulator.
With the empty editor window ready to accept text, paste a .FTH file into the
editor.  The press escape to get to the save menu. Save the file in the default
DV80 Format to the DSK1 DSK2 or DSK3.  

After this you can INCLUDE DSKX.<MYFILE> like normal ANS/ISO Forth.
