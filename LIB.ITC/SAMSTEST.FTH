\ testing read write speeds to SAMS memory

NEEDS >VIRT  FROM DSK1.VIRTUALMEM
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE

HEX
7FFF CONSTANT 32K
FFFF CONSTANT 64K

1 SEGMENT  \ select the segment we will use

: ERASE    0 FILL ;
: BLANKS  BL FILL ;

\ 32k single byte writes to paged memory
: 32KcellsSAMS    64K 0 DO   I  I !L    2 +LOOP ;

\ 64K  byte writes
: 64KB-RAM    64K 0 DO  I  3000 C!    LOOP ;  \ 14.2 secs
: 64KBSAMS    64K 0 DO  I  3000 C!L   LOOP ;  \ 45 secs

\ 32k word writes to paged memory
: 32KWORDS    32K 0 DO  I  I !L    2 +LOOP ;  \ 12.6

\ 32K word writes to normal address
: 32KTEST     32K 0 DO  I  3000 !   2 +LOOP ; \ 9.7 secs

\ 4K block fill to paged memory
: 64KBLANKS   64K 0 DO I PAGED 4K BLANKS  4K +LOOP ; ( 1.5 secs)

\ 4K block fill to CPU memory
: 64KTEST     64K 0 DO  3000 4K BLANKS    4K +LOOP ; ( 1.5 secs)

: SEE32K      64K 0 DO  I @L . 2+ LOOP ;

: 64KERASE    64K 0 DO I PAGED 4K ERASE   4K +LOOP ;

: ERASE960K  10 1 DO  I SEG !   64KERASE   LOOP ;  ( 20.7 secs)
