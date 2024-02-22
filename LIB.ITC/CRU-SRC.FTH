\ CRU support for CAMEL99   BJFOX 6FEB2018
\ rewrite Feb 2024

NEEDS MOV, FROM DSK1.ASM9900

HERE

\ access R12 from Forth
DECIMAL

CODE R12!  ( u -- ) TOS R12 MOV, NEXT, ENDCODE

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

CODE CRUC@ ( cru --- c )
    TOS R12 MOV,
    TOS 8 STCR, 
    TOS 8 SRA,  
    NEXT,
    ENDCODE

HEX 
CODE CRUC! ( data CRU --)
    TOS R12 MOV,
    TOS POP,  
    TOS 8 LDCR, 
    TOS POP,
    NEXT,
ENDCODE

HEX 
CODE LDCR ( data bits CRU-- )
    TOS   R12 MOV,
    *SP+   R1 MOV,  \ bits -> R1
    *SP+   R0 MOV,  \ data -> R0
    R1 000F ANDI,   \ test #bits<>zero
    NE IF, 
        R1 8 CI,    \ test #bits<=8  
        LTE IF,
            R0 SWPB, \ swap the data byte
        ENDIF,
    ENDIF,
    R1 06 SLA,      \ slide bits to correct instruction field 
    R1 3000 ORI,    \ create: R0 bits LDCR,
    R1 X,           \ execute the intruction
    TOS POP,
    NEXT,
ENDCODE


\ Performs the TMS9900 STCR instruction. The bit count is n1.
\ The CRU base is set first with CRU! The returned value is n2.
CODE STCR ( bits cru --- n )
    TOS R12 MOV,
    *SP+ R1 MOV,   \ bits ->R1
    TOS CLR,       \ R4 is the output ie: TOS cache 
    R1 000F ANDI,
    R1 R2 MOV,
    R1 06 SLA,
    R1 3404 ORI,   \ create R4 bits STCR,
    R1 X,          \ execute the intruction
    R2 R2 MOV, NE  \ #bits<>0  
    IF,         
        R2 08 CI, LTE  \ #bits<=8 
        IF, 
            TOS SWPB,  
        ENDIF,
    ENDIF,
    TOS SWPB, 
    NEXT,
    ENDCODE

HERE SWAP - DECIMAL  CR . .( bytes)

