EA3LOADER Read me file      Aug 10 2021

The LINKERIII program is updated in 2024 to correctly handle external references in multiple files. It enforces a "define before reference" rule like Forth or PASCAL. 
This means there is no "forward referencing". 

Having the linker lets you bring TI-99 object code developed with
the TI-99 Editor/Assembler into the Camel99 Forth environment. It is not as
simple as writing Assembler code in Forth Assembler but it will let you use
your existing code. If the code is written with a final "B *R10" (and you don't destroy the contents of R10) programs can be run and return to the Forth console. 

See the /src folder for the PC format source code. 
The TI-99 format files are in the /bin folder of the /UTILS/Linker repository.

The Camel99 system disk must be in DSK1. and the linker files can be in
DSK2. or a disk of your choice. 

The demo video on Youtube shows building LINKERIII and then linking a video device library and an application program that is run. 


