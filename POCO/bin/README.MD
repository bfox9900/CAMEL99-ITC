# POCO Resident editor for Camel99 Forth

This folder contains source code for poco editor in TI-99 file format.
It can make a version for normal expansion RAM or
a version that works with the Editor/Assembler Supercart
with 8K of RAM in the cartridge.

### How to build POCO for expansion RAM

- You the need the Editor/Assembler (E/A) cartrige plugged into TI-99
- You need the CAMEL99 disk in DSK1.
- You need the files in this folder in DSK2.
- Select Menu Option 5 from the E/A menu.
- At the file name prompt type:  DSK1.CAMEL99
- When Forth is running type: INCLUDE DSK2.POCO,MAK
    - NOTICE it's a comma not a period in the name
- After about 2 minutes the finished program will be saved onto DSK2.


### SuperCart POCO Build

Use the same staps as above but at the file name prompt type:
`
DSK1.CAML99SC
`

Then at the Forth console type:
`
INCLUDE DSK2.POCOSC,MAK
`