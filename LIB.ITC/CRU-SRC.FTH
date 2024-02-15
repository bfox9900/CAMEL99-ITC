\ CRU support for CAMEL99   BJFOX 6FEB2018
\ rewrite Feb 2024

NEEDS MOV, FROM DSK1.ASM9900

HERE

\ access R12 from Forth
DECIMAL
12 CELLS USER 'R12  

HEX
CODE SBO ( c -- ) 
    TOS 1D00 ORI,
    TOS X, 
    TOS POP,
    NEXT,
ENDCODE

CODE SBZ ( c -- ) 
    TOS 1E00 ORI,  
    TOS X, 
    TOS POP,
    NEXT,
ENDCODE

CODE TB ( c -- ? ) 
    TOS R0 MOV,
    TOS CLR,
    R0 1F00 ORI,
    R0 X,
    EQ IF, 
       TOS SETO, 
    ENDIF,
    NEXT,
ENDCODE

\ fetch/store 8 bits on the CRU buss 
\ R12 must be preset before use
CODE CRUC@ ( char --)
    TOS PUSH,  
    TOS 8 STCR,
    TOS 8 SRA,
    NEXT, 
ENDCODE 

CODE CRUC! ( char --) 
    TOS SWPB,
    TOS 8 LDCR,
    TOS POP,
    NEXT,
ENDCODE 

\ Traditional FORTH 8bit "PORT" I/O fetch and store

CODE PC@  ( CRUaddr -- c)
    TOS R12 MOV,  
    TOS 8 STCR,
    TOS 8 SRA,
    NEXT,
ENDCODE

CODE PC! ( c CRUaddr --)
    TOS R12 MOV, 
    TOS POP,
    TOS SWPB,
    TOS 8 LDCR,
    NEXT,
ENDCODE

HERE SWAP - DECIMAL  CR . .( bytes)
