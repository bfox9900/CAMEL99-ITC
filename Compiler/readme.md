 # *NEW* XFCC99.EXE for ITC or DTC Builds

**  APOLOGY in ADVANCE **
This repository is not a mirror image of the file system needed to compile the system.
Documentation on re-building the system is forthcoming.
Review the source code INCLUDE statements to make a DOS directory structure to match or change the INCLUDE statements in the source coode.

This folder contains the source code for XFCC99.EXE and the executable file.

It is here for your reference. The hope is that the source code will explain how this cross compiler was built.
The cross-compiler was created with HsForth which is an old commercial system for DOS written by the late Jim Kalihan (R.I.P.) founder of Harvard Softworks.


You can you use XFC99D.EXE IN DOSBOX as follows

Create a CAMEL99 fold as the root directory for yourself and un-zip the file  
XFC99D.ZIP into that folder.

You should have XFC99D.EXE in your CAMEL99 folder

Create a folder \CC9900
Copy the folder SRC.ITC to \CC9900  creating  \CC9900\SRC.ITC

At you ROOT folder that your made in the first step:
type:
c:\ XFC99D FLOAD CC9900\SRC.ITC\CAMEL267.HSF  <enter>

XFC99D will search the current directory and also look in the \LIB directory if you create one under the current directory.  Other than that you must explicitly spell out the file path to the source code.
