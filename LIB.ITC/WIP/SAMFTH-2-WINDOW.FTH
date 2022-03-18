\ SAMS CARD support for CAMEL99 Forth in Forth May 2020  B Fox
\ 64K segmented memory fetch and store using 2 SAMS windows
\
NEEDS BLOCK FROM DSK1.SBLOCKS

HERE
VARIABLE SEG
\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
         DUP 1 17 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;  \ don't allow segment 0 for safety

1 SEGMENT
\ Alternate methods
\ : PAGE#  ( addr -- offset bank#)  DUP 0FFF AND SWAP 0C RSHIFT  ;
\ : >PAGE# ( addr -- offset bank#)  0 1000 UM/MOD ;
HEX
CODE >PAGE# ( addr -- offset bank#)
      TOS   R0 MOV,
      R0  0FFF ANDI,   \ mask upper 4 bits
            R0 PUSH,   \ push to memory stack
       TOS  0C SRA,    \ divide by 4096
               NEXT,
ENDCODE \ 130 cycles

\ CODE >PAGE# ( addr -- n n )
\        R0   1000 LI,    \ divisor->R0                 20
\        TOS  R5 MOV,     \ MOVE low word to r5         18
\        TOS  CLR,        \ high word in TOS            14
\        R0  TOS DIV,     \ perform unsigned division  110
\        R5  PUSH,        \ push remainder              44
\        NEXT,
\ ENDCODE                                        \ 206 cycles !!

: PAGED  ( addr -- addr') >PAGE# SEG @ + BLOCK + ;

\ SAMS memory fetch and store using 2 windows
: C@S    ( addr -- n)  PAGED C@ ;   \ fetch a byte
: C!S    ( n addr -- ) PAGED C! ;   \ store a byte

: @S     ( addr -- n)  PAGED @ ;    \ fetch an int
: !S     ( n addr -- ) PAGED ! ;    \ store an int

\ SAMSINI SAMS-ON   ( un-comment for real iron)
CR .( SAMS card activated)
CR HERE SWAP - DECIMAL . .( bytes)
