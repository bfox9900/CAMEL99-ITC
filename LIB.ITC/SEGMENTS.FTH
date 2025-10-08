\ SEGMENTS.FTH   a SAMS card memory management tool   Jun 2022

\ Concept: Using 32bit addressing is awkward in a 16 bit Forth.
\          Partitioning 1Mbyte into SEGMENTS from 4K to 64K in size is practical.
NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
NEEDS SAMSINI FROM DSK1.SBLOCKS

DECIMAL

VARIABLE SEGLINK    \ last segment defined ( nfa)
VARIABLE SPP        \ sams page pointer

\ index fetches to get read segment data structure
CODE [2]@  ( addr -- n)  2 (TOS) TOS MOV,  NEXT, ENDCODE
CODE [4]@  ( addr -- n)  4 (TOS) TOS MOV,  NEXT, ENDCODE
CODE [6]@  ( addr -- n)  6 (TOS) TOS MOV,  NEXT, ENDCODE
CODE [8]@  ( addr -- n)  8 (TOS) TOS MOV,  NEXT, ENDCODE
CODE [10]@ ( addr -- n) 10 (TOS) TOS MOV,  NEXT, ENDCODE
CODE [i]@  ( n addr -- n)  *SP+ TOS MOV,  *TOS TOS MOV, NEXT, ENDCODE

: ALLOTSAMS ( n -- ) SPP +! ;

: >PAGES   ( bytes -- n ) DUP 0  4096 UM/MOD  SWAP 0> IF 1+ THEN ;

: ?FULFILL  ( n --)  SPP @ +  LASTSAM @ > ABORT" SAMS full!" ;

\ Make the root segment. ie: 1st 64K used by TI-99
CREATE SEG0
       HERE
    \  1STPAGE LASTPAGE  bytes     used     name            link
        0 ,       15 ,   65535 ,  65535 ,  LATEST @ ,  SEGLINK @ ,  SEGLINK !

: SEGMENT   ( bytes -- addr)
  CREATE
       SPP @ ,                    \ first sams PAGE used
       >PAGES  SPP @ OVER + ,     \ last sams page used
       DUP ALLOTSAMS              \ reserve these pages
       4096 * ,                   \ bytes allocated
           0  ,                   \ bytes used
       LATEST @ ,
       SEGLINK @ , SEGLINK !
  DOES> @ BLOCK  ;
