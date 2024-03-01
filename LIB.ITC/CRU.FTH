\ CRU support for CAMEL99   BJFOX 6FEB2018
\ rewritten to take CRU address from the data stack

HERE
DECIMAL
12 CELLS USER 'R12  \ access R12 from Forth

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

CODE TB ( c -- ? ) \ builds instruction at runtime Why?
        C004 ,        \ TOS R0 MOV,
        04C4 ,        \ TOS CLR,
        0260 , 1F00 , \ R0 1F00 ORI,
        0480 ,        \ R0 X,
        1601 , 0704 , \ EQ IF, TOS SETO, ENDIF,
        NEXT,
        ENDCODE

\ fetch store 8 bits on the CRU buss 
CODE CRUC@ ( char -- )
       3204 , \ TOS 8 LDCR,
       0884 , \ TOS 8 SRA,
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

CODE LDCR ( data #bits -- )
     C044 ,        \ TOS    R1 MOV,  \ bits -> R1
     C036 ,        \ *SP+   R0 MOV,  \ data -> R0
     0241 , 0F ,   \ R1 000F ANDI,  \ instruction built in R1
     1304 ,        \ NE IF,
     0281 , 08 ,   \     R1 8 CI,
     1501 ,        \     LTE IF,
     06C0 ,        \          R0 SWPB,   \ swap the data byte
                   \     ENDIF,
                   \ ENDIF,
     0A61 ,        \ R1 06 SLA,
     0261 , 3000 , \ R1 3000 ORI,   \ create: R0 bits LDCR,
     0481 ,        \ R1 X,          \ execute the intruction
     C136 ,        \ TOS POP,
     NEXT,
     ENDCODE

\ Performs the TMS9900 STCR instruction. The bit count is n1.
\ The CRU base is set first with: ; xxxx 'R12 ! 
CODE STCR ( #bits -- n )
     C044 ,        \ TOS R1 MOV,   \ bits ->R1
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
     C100 ,        \ R0 TOS MOV,
     NEXT,
     ENDCODE



\ DETACH 
HERE SWAP - DECIMAL  CR . .( BYTES)
