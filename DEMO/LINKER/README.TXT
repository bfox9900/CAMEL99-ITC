EA3LOADER Read me file      Aug 10 2021

The file EA3LOADER.FTH creates a way to bring object code developed with
the TI-99 Editor Assembler into the Camel99 Forth environment. It is not as
simple as writing Assembler code in Forth Assembler but it might let you use
existing code.

The file exists in the DSK4. folder of the repository as a TI-99 text file.

INCLUDE DSK4.EA3LOADER  \ Linking loader
INCLUDE DSK4.EXTERNS    \ create Forth words to call extern code

NEW.
OLOAD DSK4.CLS-OBJ
DEFS CLS   FORTH EXTERN: CLEAR

\ Now  the DEF CLS can be called as the Forth word CLEAR
