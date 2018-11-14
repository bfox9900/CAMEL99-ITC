\ CRU support for CAMEL99   BJFOX 6FEB2018
\ INCLUDE DSK1.TOOLS

HERE
HEX
CODE CRU! ( CRUaddr -- )   \ load CRU adr to R12
        C304 ,       \ TOS R12 MOV, 
        C136 ,       \ TOS POP,
        NEXT,
        ENDCODE

CODE CRU@  ( -- CRUaddr ) \ read R12 to TOS
        0646 , C584 , \ TOS PUSH,
        C10C ,        \ R12 TOS MOV,
        NEXT,
        ENDCODE

\ *set the CRU address before using these words*

\ fastest for bit 0
CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE
CODE 0TB   ( -- ) 1F00 ,  NEXT, ENDCODE

\ slower but bit variable
CODE SBO ( c -- )
        0264 , 1D00 , \ TOS 1D00 ORI,
        0484 ,        \ TOS X,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

CODE SBZ ( c -- )
        0264 , 1E00 , \ TOS 1E00 ORI,
        0484 ,        \ TOS X,
        C136 ,        \ TOS POP,
        NEXT,
        ENDCODE

CODE TB ( c -- ? )
        C004 ,        \ TOS R0 MOV,
        04C4 ,        \ TOS CLR,
        0260 , 1F00 , \ R0 1F00 ORI,
        0480 ,        \ R0 X,
        1601 , 0704 , \ EQ IF, TOS SETO, ENDIF,
        NEXT,
        ENDCODE

HERE SWAP - DECIMAL  CR . .( BYTES)
