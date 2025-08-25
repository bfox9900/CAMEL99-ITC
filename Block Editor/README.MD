# BLock Editor for 80 Column Screen

This is a simple editor for use with "block" files.

** This editor requires the F18 video card or equivalent because it uses
   80 column screen format.

It is compatible with the block files used by TurboForth and FbForth so you can use it to persuse those system's code using Camel99 Forth.

A block file a binary file that is read as blocks of 1K bytes.
This was the traditional way the Forth accessed disk in the early days.

The BLOCK files are in a TI-99 file format called "DISPLAY FIXED 128"
if use the TI BASIC syntax.


### Compiling the Block Editor
- You must have the Camel99 Forth disk with library files in DSK1.
- Copy the binary version of the source from the /bin folder to your chosen disk
- Copy the BLOCK file in the /bin folder to you chosen disk (it has 53 1K blocks)
- Start Camel99 Forth or Camel99SC Forth (Super Cart version)
- At the Forth console type:  INCLUDE DSK?.BLOCKEDIT
    - Where? is the disk number with the BLOCKEDIT program

- The program will take some time to compile.
    - (1 minute on Classic99, 2 minutes with floppy disk)

### Using the Editor

You must open a block file to get started like this:
```
USE DSK2.BLOCKS
```

To display and edit a block use the EDIT command prefaced with the block number:
```
5 EDIT
```

### Block Editor Key Commands.

  TI-99 FCTN KEY   PC Keyboard

  DELETE            Delete      deletes 1 char and shortens line by 1 char
  INSERT            Insert      toggles between inserting or overwrite mode
  ERASE             Alt 3       erases 1 line & stores in a buffer stack
  CLEAR             PageDown    displays the next disk block
  BEGIN             Home        homes cursor to top of block
  PROCEED           PaeUp       displays the previous disk block
  AID                N/A        (future) delete line from right of cursor
  REDO              Alt 8       Inserts ERASEd line at cursor's row
  BACK              Escape      returns to FORTH console

  "E"               Up Arrow    move the Cursor up
  "X"               Down Arrow  move the Cursor down
  "S"               Left Arrow  move the Cursor left
  "D"               Rigth Arrwo move the Cursor right


CTRL KEYS    ( CTRL key must be held down )
  "S"    Save all updated buffers to disk
  "P"    Paste copy buffer at row line (overwrites)
  "C"    Copy line at cursor to copy buffer stack (non-destructive)
  "X"    Extract line at cursor and copy to buffer stack
  "V"    Paste copy buffer to line and push lines down

FORTH COMMANDS         Function Performed

  USE <path>      Open a block file for editing
  EDIT            edit selected block number (number precedes command)
  ED              Invokes editor at active block

  TEXT or T ....  Switch to TEXT display mode.

  COLD      ....  re-starts FORTH from scratch.
