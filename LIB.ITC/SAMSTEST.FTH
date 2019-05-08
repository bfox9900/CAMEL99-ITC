\ testing read write speeds to SAMS memory
 
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
 
HEX
7FFF CONSTANT 32K
FFFF CONSTANT 64K
1000 CONSTANT 4K
 
1 SEGMENT  \ select the segment we will use
 
: ERASE    0 FILL ;
: BLANKS  BL FILL ;
 
\ 64k single byte writes to paged memory      \ OLD       NEW
: 64KBYTES    64K 0 DO  I     I C!P    LOOP ; \ 47 secs  30.5
: 64KWORDS    64K 0 DO  I     I  !P    LOOP ; \          29.6

\ 64K single byte writes to NORMAL address
: 64KBTEST    64K 0 DO  I  3000 C!    LOOP ;  \ 15 secs

\ 32k word writes to paged memory               \
: 32KWORDS    64K 0 DO  I  I     !P   2 +LOOP ; \ 25.5 secs 17.4

\ 32K word writes to normal address
: 32KTEST     64K 0 DO  I  3000  !    2 +LOOP ; \ 9.7 SECS

\ 4K block fill to paged memory
: 64KBLANKS   64K 0 DO I PAGED 4K BLANKS  4K +LOOP ; ( 1.5 secs)
 
\ 4K block fill to CPU memory
: 64KTEST     64K 0 DO  3000 4K BLANKS    4K +LOOP ; ( 1.5 secs)
 
: SEE32K      64K 0 DO  I @P . 2+ LOOP ;
 
: 64KERASE    64K 0 DO I PAGED 4K ERASE   4K +LOOP ;
 
: ERASE960K  10 1 DO  I SEG !   64KERASE   LOOP ;  ( 20.7 secs)
 
