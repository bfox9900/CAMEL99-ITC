\ CRU support for CAMEL99   BJFOX 6FEB2018
\ rewritten to take CRU address from the data stack

HERE
DECIMAL
12 CELLS USER 'R12  \ access R12 from Forth

DECIMAL 
24 USER 'R12  \ address of R12 for any workspace (task)

HEX
CODE SBO ( c -- ) \ set CRU bit to ONE
        0264 , 1D00 ,  \ TOS 1D00 ORI,
        0484 ,         \ TOS X, 
        C136 ,         \ TOS POP,
        NEXT,
        ENDCODE

CODE SBZ ( c -- ) \ set CRU bit to ZERO
        0264 , 1E00 ,  \ TOS 1E00 ORI,  
        0484 ,         \ TOS X, 
        C136 ,         \ TOS POP,
        NEXT,
        ENDCODE

CODE TB ( c -- ?) \ test CRU bit 
        0264 , 1F00 ,  \ TOS 1F00 ORI,  
        0484 ,         \ TOS X, 
        NEXT,
        ENDCODE

\ fetch store 8 bits on the CRU buss 
CODE CRUC@ ( char -- )
       3204 , \ TOS 8 LDCR,
       0884 . \ TOS 8 SRA,
       NEXT, 
ENDCODE 

CODE CRUC!  ( -- char)
      06C4 , \ TOS SWPB,
      3604 , \ TOS 8 STCR,
      C136 , \ TOS POP,
      NEXT,
ENDCODE 

\ Traditional 8bit "PORT" I/O fetch and store
CODE PC@  ( CRUaddr -- c)
     C304 , \ TOS R12 MOV,  
     3204 , \ TOS 8 LDCR,
     0884 . \ TOS 8 SRA,
     NEXT,
ENDCODE

CODE PC!  ( c CRUaddr --)
       C304 , \ TOS R12 MOV, 
       06D6 , \ *SP SWPB,
       3636 , \ *SP+ 8 STCR,
       C136 , \ TOS POP,
       NEXT,
ENDCODE

\ DETACH 
HERE SWAP - DECIMAL  CR . .( BYTES)
