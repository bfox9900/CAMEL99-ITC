 # *NEW* FCC99d.EXE for ITC or DTC Builds

**  APOLOGY in ADVANCE **
This repository is not a mirror image of the file system needed to compile the system. 
Documentation on re-building CAMEL99 FORTH is below.

Review the source code INCLUDE statements to understand the DOS directory structure 
needed to match the INCLUDE statements in the CAMEL99 FORTH source coode.

This folder contains the source code for FCC99d.EXE cross-compiler in bin folder

The cross-compiler source code is here for your reference. There are ample comments in the code so the hope is that the source code will explain how this cross compiler was built. The cross-compiler was created with HsForth which is an old commercial system for DOS written by the late Jim Kalihan (R.I.P.) founder of Harvard Softworks.

#### Use FCC99E.EXE IN DOSBOX as follows:

Create a CAMEL99 folder as the root directory for yourself and un-zip the file  
FCC99E.ZIP into that folder.

This will give you the cross-compiler FCC99E.EXE in your CAMEL99 folder

Create a folder \CC9900
Copy the folder SRC.ITC to \CC9900  creating  \CC9900\SRC.ITC 

At your ROOT folder that you made in the first step type:

```
c:\ FCC99E FLOAD CC9900\SRC.ITC\FORTHITC.MAK  <enter>
```
(This not a "make" file, but Forth language that is interpreted)

FCC99E will search the current directory and also look in the CAMEL99\LIB directory 
if you create \LIB in CAMEL99

Source code that is not in CAMEL99 folder or the \LIB folder must explicitly 
spelled out in the file path in your source code.

If you need help look me up on atariage.com  @theBF 
