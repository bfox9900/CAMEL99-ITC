 # FORTH Cross-Compiler, FCC99.EXE for ITC or DTC 

This folder contains the source code for FCC99D.EXE and the executable file.

It is here for your reference. The hope is that the source code will explain how this cross compiler was built.
The cross-compiler was created with HsForth which is an old commercial system for DOS written by the late Jim Kalihan (R.I.P.) founder of Harvard Softworks.

The cross compiler program is in the bin folder as a Zip file. 
It is called FCC99D.EXE when you unzip it. It is a heavily extended Forth system. 

You can you use FCC99D.EXE IN DOSBOX as follows

Create a CAMEL99 folder as the root directory for yourself and un-zip the file  
FCC99.ZIP into that folder.

You should then have FCC99D.EXE in your CAMEL99 folder

Create a folder \CC9900
Copy the folder SRC.ITC to \CC9900  creating  \CC9900\SRC.ITC

At your ROOT folder that you made in the first step:
type:
c:\ FCC99D FLOAD CC9900\SRC.ITC\FORTHITC.MAK <enter>

The build process is controlled by the .MAK file which is a script 
written in Forth, NOT a file for the make utility program. 

Some SOURCE code files also contain INCLUDE statements with explicit
directories. It's not pretty (it's ugly) but I got it to work. 
