# BLock Editor for 80 Column Screen

This is a simple editor for use with "block" files.

** This editor requires the F18 video card or equivalent because it uses
   80 column screen format.

It is compatible with the block files used by TurboForth and FbForth so you can use it to peruse those system's code while in Camel99 Forth.

A block file is a file that is read as blocks of 1K bytes.
This was the traditional way the Forth accessed disk in the early days.

The BLOCK files are in a TI-99 file format called "DISPLAY FIXED 128"
if we use the TI BASIC syntax.


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

#### Copybuffer Stack
This editor makes use of a stack to hold lines of text that are copied or "Xtracted"
*WARNING*
It is best to play with the cut/copy/paste before touching anything serious because inserting (control V) a line pushes down the lines below so that the bottom line will disappear.
If that happens press ESCAPE and type UNDO ED to get back to the original block text.


### Block Editor Key Commands.
```
#### TI-99 FCTN KEY |PC Keyboard

  DELETE            Delete      deletes 1 char and shortens line by 1 char
  INSERT            Insert      toggles between inserting or overwrite mode
  ERASE             Alt 3       erases 1 line & stores in a buffer stack
  CLEAR             PageDown    displays the next disk block
  PROCEED           PageUp      displays the previous disk block
  BEGIN             Home        homes cursor to top of block
  REDO              Alt 8       Inserts ERASEd line at cursor's row
  BACK              Escape      returns to FORTH console

  "E"               Up Arrow    move the Cursor up
  "X"               Down Arrow  move the Cursor down
  "S"               Left Arrow  move the Cursor left
  "D"               Right Arrwo move the Cursor right
```

#### CTRL KEYS
```
  "S"               Save all updated buffers to disk
  "P"               Paste copy buffer at row line (overwrites)
  "C"               Copy line at cursor to copy buffer stack (non-destructive)
  "X"               Extract line at cursor and copy to buffer stack
  "V"               Paste copy buffer to line and push lines down
```

#### FORTH Console Commands
The editor words are compiled into a separate vocabulary called EDITOR.
When the editor is compiled the default search order for the dictionary is:
```
EDITOR  FORTH-WORDLIST ROOT
CURRENT: EDITOR    ( where new words will be compiled)
```

To see the search order use the command: ORDER
If you change the order you can get back to having the EDITOR first with:
```
EDITOR
```

If by chance you really mess up the search order type this:
```
ONLY FORTH ALSO EDITOR DEFINITIONS
```


At the Forth console with the EDITOR in the search order you have a few
commands at your disposal listed below.

```
  USE <path>        Open a block file for editing
  CLOSE-BLOCKS      Close the open block file

  EDIT              Edit selected block number (number precedes command)
  ED                Invokes editor at active block

  >>                List the next block
  <<                List the previous block

  SAVE              Save all updated buffers
  UNDO              Empty all buffers. This will refill un-saved data from disk

  7 CLEAR           erase contents of a block 7 and update buffer

  TEXT              Switch to 40 column TEXT display mode

  50 S" DSK3.MYBLOCKS" MAKE-BLOCKS  creates a new file with 50 blocks ON DSK3.

  COLD              re-starts FORTH from removes editor
```
