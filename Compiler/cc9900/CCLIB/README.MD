# CCLIB FOR CAMEL99

This folder contains legacy code that was primarily used in testing pieces of
the system before the final Forth progam was running. 

The method used was to compile parts of the system and write small Forth programs
to exercise the new components. This was done until a working system emerged.

It is preferable now to use the files in LIB.ITC and preface them with the appropriate compiler commands. 


TARGET-COMPILING    \ used before compiling 
[TC]                \ short form for target-compiling

CROSS-COMPLING      \ use for interpreted functions 
[CC]                \ short form for CROSS-COMPILING 

[CC]  HEX  [TC]     \ changing radix during compiling 
