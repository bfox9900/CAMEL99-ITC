\ BLWP  Call a sub-program from Forth and return to Forth
\       See example code to create your own sub-program

HEX
CODE BLWP  ( daddr -- )  \ "BULLWHIP" takes a 2VARIABLE as input arg.
     0414 , \ *TOS BLWP, \ BLWP loads the workspace and program counter into CPU
     C136 , \  TOS POP,  \ refill Forth TOS when we get back from our journey
     NEXT,               \ return to Forth 
     ENDCODE

\ --------------------------------------------------------
\ Example code:
 NEEDS DUMP FROM DSK1.TOOLS
 NEEDS MOV, FROM DSK1.ASM9900
 
 \ Note the use of CREATE not CODE 
 CREATE SUBPROG ( -- addr) \ NOT RUNNABLE FROM FORTH. Must call with BLWP 
       R1 1111 LI,         \ Init some registers in foreign workspace
       R2 2222 LI,
       R3 3333 LI,
       R4 4444 LI,
       R5 5555 LI,
       R6 6666 LI,
       R7 7777 LI, 
       R8 8888 LI,
       R9 9999 LI, 
       RTWP,         \ *** MUST END WITH RTWP, ***

DECIMAL 
 CREATE WKSP2    16 CELLS ALLOT     \ allot space for the new workspace 
 
 \ 9900 needs a "vector" that consists of a workspace and an entry address for the code 
 CREATE MYVCTR   WKSP2 ,  SUBPROG , \ make a 9900 vector 

 : CLRWKSP ( addr ) 16 CELLS 0 FILL ; \ erase a workspace 

WKSP2 CLRWKSP  
\ Run with: MYVCTR BLWP
\ Examine Results:  WKSP2  16 CELLS  DUMP
