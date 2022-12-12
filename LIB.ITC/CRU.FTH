\ CRU support for CAMEL99   BJFOX 6FEB2018
\ rewritten to take CRU address from the data stack
NEEDS TRANSISENT FROM DSK1.TRANSIENT

TRANSIENT
INCLUDE DSK1.ASM9900


PERMANENT
HERE
DECIMAL
12 CELLS USER 'R12  \ access R12 from Forth

HEX
\ Use Machine code compilers to make fast CODE words for BITS that you need
: >SBO, ( bit# --) 1D00 + , ;
: >SBZ, ( bit# --) 1E00 + , ;
: >TB,  ( bit# --) 1F00 + , ;

\ *set the CRU address in 'R12 before using these words*
CODE 0SBO  ( -- ) 0 >SBO,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 0 >SBZ,  NEXT, ENDCODE
CODE 0TB   ( -- ) 0 >TB,   NEXT, ENDCODE

\ slower but bit variable
CODE SBO ( CRUaddr -- )
        R12 RPUSH,
        TOS R12 MOV,
        0 SBO,
        R12 RPOP,
        TOS POP,
        NEXT,
        ENDCODE

CODE SBZ ( CRUaddr -- )
        R12 RPUSH,
        TOS R12 MOV,
        0 SBZ,
        R12 RPOP,
        TOS POP,
        NEXT,
        ENDCODE

CODE TB ( CRUaddr -- ? )
        R12 RPUSH,
        TOS R12 MOV,
        0 TB,
        TOS CLR,
        EQ IF, TOS SETO, ENDIF,
        R12 RPOP,
        TOS POP,
        NEXT,
        ENDCODE

\ Traditional PORT character fetch and store are more efficient in Forth
CODE CRUC@  ( CRUaddr -- c)
        R12 RPUSH,    \ save R12
        TOS R12 MOV,  \ set new CRU address
        TOS 8 LDCR,
        TOS 8 SRA,
        R12 RPOP,     \ restore R12
        NEXT,
ENDCODE

CODE CRUC!  ( c CRUaddr --)
        R12 RPUSH,    \ save R12
        TOS R12 MOV,  \ set new CRU address
        TOS POP,      \ get c into TOS register
        TOS SWPB,
        TOS 8 STCR,   \ write eight bits
        R12 RPOP,     \ restore R12
        TOS POP,      \ refill TOS register from memory stack
        NEXT,
ENDCODE

DETACH CR .( *Transient code is removed*)
HERE SWAP - DECIMAL  CR . .( BYTES)
