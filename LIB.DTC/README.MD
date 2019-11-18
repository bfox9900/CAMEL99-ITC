# TI-99 Library Files for Direct Threaded SYSTEM

### lib.dtc

This folder provides an proper SYSTEM file for CAM99DTC.  It needs to be converted
to a TI-99 file to be included.  Since CAM99DTC is not finished it does not automatically
include the START file.  To include the DTC SYSTEM file, after it is converted
type:  S" DSK1.SYSTEM" INCLUDE


### Usage
The are the text files in PC format that you can edit. To use them on real TI-99
hardware they must be converted to TI-99 FILES. This can be done by starting
the TI Editor in the Editor/Assembler cartridge on the Classic99 emulator.
With the empty editor window ready to accept text, paste a .FTH file into the
editor.  The press escape to get to the save menu. Save the file in the default
DV80 Format to the DSK1 DSK2 or DSK3.  

After this you can INCLUDE DSKX.<MYFILE> like normal ANS/ISO Forth.
