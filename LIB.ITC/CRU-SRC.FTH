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

CODE LDCR ( data bits CRU-- )
    TOS   R12 MOV,
    *SP+   R1 MOV,  \ bits -> R1
    *SP+   R0 MOV,  \ data -> R0
    R1 000F ANDI,  \ instruction built in R1
    NE IF,
         R1 8 CI,
          LTE IF,
               R0 SWPB,   \ swap the data byte
            ENDIF,
        ENDIF,
    R1 06 SLA,
    R1 3000 ORI,   \ create: R0 bits LDCR,
    R1 X,          \ execute the intruction
    TOS POP,
    NEXT,
ENDCODE

\ Performs the TMS9900 STCR instruction. The bit count is n1.
\ The CRU base is set first with CRU! The returned value is n2.
CODE STCR ( bits cru --- n )
     C304 ,        \  TOS R12 MOV,
     C076 ,        \ *SP+ R1 MOV,   \ bits ->R1
     04C0 ,        \  R0 CLR,       \
     0241 , 0F ,   \ R1 000F ANDI,
     C081 ,        \ R1 R2 MOV,
     0A61 ,        \ R1 06 SLA,
     0261 , 3400 , \ R1 3400 ORI,  \ create R0 bits STCR,
     0481 ,        \ R1 X,         \ execute the intruction
     C082 ,        \ R2 R2 MOV,
     1304 ,        \ NE IF,
     0282 , 08 ,   \     R2 08 CI,
     1501 ,        \     LTE IF,
     06C0 ,        \          R0 SWPB,
                   \     ENDIF,
                   \ ENDIF,
     C100 ,         \ R0 TOS MOV,
     NEXT,
     ENDCODE



HERE SWAP - DECIMAL  CR . .( bytes)
