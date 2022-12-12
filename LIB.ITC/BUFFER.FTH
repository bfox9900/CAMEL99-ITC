\ Forth 2012 word BUFFER:

\ Standard definition
 : BUFFER: ( n --)  CREATE ALLOT ;

NEEDS MALLOC FROM DSK1.MALLOC 
\ TI-99 specific Low RAM buffer creator
: LOWBUFFER: ( n -- )
             DUP H @ + 3FFF > ABORT" "
             MALLOC CONSTANT ;        