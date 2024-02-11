\ CRUSMALL.FTH minimal CRU support for CAMEL99   BJFOX 6FEB2018

HERE 
DECIMAL 
24 USER 'R12  \ address of R12 for any workspace (task)
\ Usage to set CRU address use the ! operator
\ HEX  1E00 'R12 ! 

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

DECIMAL 
HERE SWAP - . .( bytes)
