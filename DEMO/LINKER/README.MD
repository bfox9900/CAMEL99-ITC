# Object File Linking loader
#### Aug 10 2021

The file EA3LOADER.FTH creates a way to bring object code developed with the
TI-99 Editor Assembler into the Camel99 Forth environment. It is not as
simple as writing Assembler code in Forth Assembler but it might let you use
existing code or allow you to work with your familiar Assembly language tools.

The files exists as TI-99 compatible files in the DSK4.OBJ folder of the
repository.

## Example Usage

INCLUDE DSK4.EA3LOADER  \ the Linking loader code

INCLUDE DSK4.EXTERNS    \ words to call external code

NEW.                    \ Initialize 8K low RAM memory and variables

OLOAD DSK4.CLS-OBJ      \ object load" a file

DEFS CLS   FORTH EXTERN: CLEAR  \ declare a DEF as a Forth word

Now the DEF CLS from the Assembler program can be called as the Forth word CLEAR
