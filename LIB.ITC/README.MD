# TI-99 Library Files PC format
These files are the same files as found in DSK1.ITC but in PC text format.
This makes them usable for experimenting with the CLASSIC99 Emulator.
You will also find some experiments and ideas that may or not be working.

## Use with CLASSIC99 Emulator

-Start the CLASSIC99 Emulator Program
-Under CARTRIDGE select APPS->Editor/Assembler
-Press a key
-Press 2 to start Editor Assembler
-Press 5  RUN PROGRAM FILE

You will see the prompt "FILE NAME?" enter:

DSK1.CAMEL99
Note: The library files assume that CAMEL99 is in DSK1.

With CAMEL99 running...
1. Open the source file you want to load with a text editor.
2. Copy the entire source file using CTRL A
3. Paste the file into CAMEL99 using the EDIT->PASTE tab on the Emulator window.

========================
IF THERE ARE ERRORS IN THE CODE...We apologize.

If you hear a TI-99 honk sound while the file is pasting there has been an
error of some kind.

In the CAMEL99 program type the command COLD <ENTER>

This will reset Forth back to a clean system.

## Debugging with CLASSIC99
Try pasting the file into CAMEL99, pieces at a time from the top of file until
you find the line with the error. Then you will have to fix the error in the
source code and test it by reloading.

If you need help contact theBF on

http://atariage.com/forums/forum/119-ti-994a-development/
