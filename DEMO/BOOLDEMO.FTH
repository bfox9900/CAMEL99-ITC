\ demo to show how to use dsk1.boolean LIBRARY

INCLUDE DSK1.BOOLEAN

\ Usage Example
 DECIMAL
 1024 CONSTANT size \ # of bits we want
 size BITS: ]X      \ make array X of size bits

\ set and reset each bit using the BSET BRST BIT@ words.
: FILLBITS   ." Setting all bits..." size 0 DO  I ]X BSET   LOOP ;
: CLRBITS    ." Erasing..."          size 0 DO  I ]X BRST   LOOP ;
: TOGGLE     ." Toggling..."         size 0 DO  I ]X BTOG   LOOP ;

: EVENBITS    CLRBITS ." Setting even bits..." size 0 DO  I ]X BSET   2 +LOOP ;
: SHOWBITS    size 0 DO  I ]X BIT@ . LOOP ;
