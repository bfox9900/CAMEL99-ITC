 # *NEW* XFCC99.EXE for ITC or DTC Builds
 
**  APOLOGY in ADVANCE **
This repository is not a mirror image of the file system needed to compile the system.
Documentation on re-building the system is forthcoming. 
Review the source code INCLUDE statements to make a DOS directory structure to match or change the INCLUDE statements in the source coode.

This folder contains the source code for XFCC99.EXE and the executable file.

It is here for your reference. The hope is that the source code will explain how this cross compiler was built.
The cross-compiler was created with HsForth which is an old commercial system for DOS written by the late Jim Kalihan (R.I.P.) founder of Harvard Softworks. We do not have permission to release the HsForth kernel to allow you to re-build the compiler at this time.

(We are considering re-making the cross-compiler with Gforth so that it accessible by everyone.)

You can you use XFCC99.EXE as follows.

At the DOS command line type:

c:\ XFCC99 FLOAD CAMEL2.HSF   <enter>

-OR-

c:\ XFCC99 FLOAD CAMDTC99.HSF   <enter>


XFCC99 will search the current directory and also look in the \LIB directory if you create one under the current directory.  Other than that you must explicitly spell out the file path to the source code.

