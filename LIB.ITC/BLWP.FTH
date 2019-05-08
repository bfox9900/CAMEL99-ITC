\ BLWP  Call a sub-program from Forth and return to Forth
\       See example code to create your own sub-program

HEX
CODE BLWP  ( daddr -- )  \ "BULLWHIP" takes a 2VARIABLE as input arg.
     0414 , \ *TOS BLWP, \ BLWP loads the workspace and program counter into CPU
     C136 , \  TOS POP,  \ refill Forth TOS when we get back from our journey
     NEXT,
     ENDCODE

\ Example code:
\ NEEDS DUMP FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900
\ CODE SUBPROG
\       R1 1111 LI,    \ Init some registers in foreign workspace
\       R2 2222 LI,
\       R3 3333 LI,
\       R4 4444 LI,
\       R5 5555 LI,
\       R6 6666 LI,
\       RTWP,         \ *** MUST END WITH RTWP, ***
\       ENDCODE

\ CREATE WKSP2    16 CELLS ALLOT              ( this is for registers)
\ CREATE MYVCTR   WKSP2 ,  ' SUBPROG >BODY ,

\ run with: MYVCTR BLWP

\ Examine Results:  WKSP2  10 DUMP
