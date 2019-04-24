# TI-99 Library Files for Direct Threaded SYSTEM

### lib.dtc

This folder provides an proper SYSTEM file for CAM99DTC.  It needs to be converted
to a TI-99 file to be included.  Since CAM99DTC is not finished it does not automatically
include the START file.  To include the DTC SYSTEM file, after it is converted
type:  S" DSK1.SYSTEM" INCLUDED 

These files have no extension because the TI-99 file system uses the '.' character to delimit device names and parameters. These files are all in the default format for assembler source code on the TI-99. This format is described as DISPLAY, VARIABLE 80 or DV80 as a short form.

DV80 means ASCII text characters are the only characters in the file and the records are 80 bytes long. They are edited with the Editor assembler Editor program (EDIT1) or the third party 80 column editor called EDIT80.
