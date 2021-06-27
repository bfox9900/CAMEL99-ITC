\ SAMS CARD expanded HEAP for Camel99 Forth   July 16 2020  Brian Fox
\ 64K of HEAP in high end of SAMS card

NEEDS 'R12 FROM DSK1.SAMSFTH
HERE
VARIABLE HEAP#
HEX 2000 CONSTANT HMEM  \ paged memory block location

\ compute SAMS register based on HMEM address
HMEM 0B RSHIFT 4000 + CONSTANT HEAPREG

HEX
: HEAPS  ( n -- addr')
       DUP HEAP# @ =      \ are we using the same PAGE
       IF
           DROP           \ Yes. Drop bank# and get out
       ELSE
           DUP HEAP# !     \ update heap# variable
           ><              \ swap bytes, heap# must be in left byte
           SAMSCARD 0SBO   \ turn on the card
         ( bank#) HEAPREG !  \ store bank in SAMS register
           0SBZ            \ turn off card
       THEN  HMEM          \ return heap address
;
CR .( HEAPS located at HEX ) HMEM .
CR HERE SWAP - DECIMAL . .( bytes)

: HEAPFILL ( heap# size byte -- )
       SAMSCARD 0SBO
       HEAPREG @ >R
       ROT HEAPREG !
       HMEM -ROT FILL
       R> HEAPREG !
;
