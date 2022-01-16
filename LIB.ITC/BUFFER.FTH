\ Forth 2012 word BUFFER:
NEEDS MALLOC  FROM DSK1.MALLOC

\ Standard definition
 : BUFFER: ( n --)  CREATE ALLOT ;

\ TI-99 specific Low RAM buffer creator
HEX
: LOWBUFFER: ( n -- )
      DUP H @ + 3FFF > ABORT" HEAP error"
      MALLOC CONSTANT ;
