\ CRU compile experiment to speed up CRU operations in Forth

\ poor man's assembler
HEX
: CRU,   ( bit# -- ) SWAP 00FF AND OR , ; \ create & compile a CRU instruction
: ?,      04C4 ,  1601 , 0704 ,  ; \ TOS CLR, EQ IF, TOS SETO, ENDIF,

\ instruction creators
: TESTCRU: ( bit# -- ?) CODE   1F00 CRU, ?,  NEXT, ENDCODE ;
: SETCRU:  ( bit# -- )  CODE   1D00 CRU, NEXT, ENDCODE ;
: RSTCRU:  ( bit# -- )  CODE   1D00 CRU, NEXT,  ENDCODE ;

DECIMAL
 7 TESTCRU: 7TB
27 TESTCRU: 7TB

21 SETCRU: 21SBO
31 SETCRU: 31SBO

21 RSTCRU: 21SBZ
31 RSTCRU: 31SBZ
