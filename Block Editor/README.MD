# BLock Editor Example

This is a simple editor for use with "block" files.
A block file a binary file that is read as blocks of 1K bytes.
This was the traditional way the Forth accessed disk in the early days.

The BLOCK files are in a TI-99 file format called "DISPLAY FIXED 128"
if use the TI BASIC syntax.

** This editor requires the F18 video card or equivalent because it uses
   80 column screen format.

### Compiling the Block Editor

- You must have the Camel99 Forth disk with library files in DSK1.
- Copy the binary version of the source from the /bin folder to your chosen disk
- In the /bin folder there is a BLOCK file with 53 1K blocks.
- Start Camel99 Forth or Camel99SC Forth (Super Cart version)
- At the Forth console type:  INCLUDE DSK?.BLOCKEDIT
    - Where? is the disk number with the BLOCKEDIT program
- The program will take some time to compile.
    - (1 min on Classic99, 2 minutes with floppy disk)
