\ SAMS TOOLS

NEEDS DUMP FROM DSK1.TOOLS
NEEDS SAMS-ON FROM DSK1.SAMS

: SDUMP ( addr len --)
       CR ." SEGMENT=" SEG @ .
       ['] @P IS MEM@
       ['] C@P IS MEMC@ (DUMP) ;

\ Erase 1 64K segment of SAMS memory at maximum speed
HEX
: ERASE       0 FILL ;
: 64KERASE    FFFF 0 DO  I PAGED 4K ERASE  4K +LOOP ;

 \ fill sams mem segment with char
: SFILL  ( addr len char -- )
        -ROT BOUNDS DO   DUP I C!P  LOOP DROP ;
