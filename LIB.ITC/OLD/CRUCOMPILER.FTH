\ CRU compile experiment to speed up CRU operations in Forth

\ poor man's assembler
HEX
8 10 + CONSTANT *R8                       \ R8 indirect (Forth W register)

: B,     ( register -- ) 0440 +  , ;      \ compile B R?  instruction
: CRU,   ( bit# -- ) SWAP 00FF AND OR , ; \ create & compile a CRU instruction
: ?,      04C4 ,  1601 , 0704 ,  ; \ TOS CLR, EQ IF, TOS SETO, ENDIF,

\ instruction creators
: TESTCRU: ( bit# -- ?)
            CREATE   1F00 CRU, ?,  NEXT, \ compile CRU instruction & test
            ;CODE
              *R8  B,
            ENDCODE

: SETCRU:  ( bit# -- )
            CREATE  1D00 CRU, NEXT,
            ;CODE
               *R8  B,
            ENDCODE

: RSTCRU: ( bit# -- )
            CREATE  1D00 CRU, NEXT,
            ;CODE
               *R8  B,
            ENDCODE
DECIMAL
 7 TESTCRU: 7TB
27 TESTCRU: 7TB

21 SETCRU: 21SBO
31 SETCRU: 31SBO

21 RSTCRU: 21SBZ
31 RSTCRU: 31SBZ
