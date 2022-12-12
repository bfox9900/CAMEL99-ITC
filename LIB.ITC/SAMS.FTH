\ SAMS CARD support. 64K segmented memory fetch and store  2022 Brian Fox
\ 1 sams page only.  Set to >3000 by PMEM (paged memory)

NEEDS SAMSINI FROM DSK1.SAMSINI

HERE
HEX
     VARIABLE BANK#      \ current mapped bank
\ 1000 CONSTANT 4K         \ bytes per bank = 4K
     VARIABLE SEG        \ holds current 64K segment

3000 CONSTANT PMEM       \ paged memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
       DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
       SEG ! ;  \ don't allow segment 0

1 SEGMENT

HEX
CODE PAGED  ( addr -- paged_address )
     0200 , 1000 ,  \ R0  4K LI,         \ 4K divisor ->R0
     C144 ,         \ TOS R5 MOV,        \ address to r5
     C120 , SEG ,   \ SEG @@ TOS MOV,    \ segment# to R4,
     3D00 ,         \ R0 TOS DIV,        \ TOS=bank#, R5=offset

     8804 , BANK# , \ TOS BANK# @@ CMP,  \ switch page ?
     1309 ,         \ NE IF,
     C804 , BANK# , \    TOS BANK# @@ MOV, \ YES, update BANK#
     06C4 ,         \    TOS SWPB,
     020C , 1E00 ,  \    R12 1E00 LI,      \ select SAMS
     1D00 ,         \    0 SBO,            \ card on
     C804 , SREG ,  \    TOS 4006 @@ MOV,  \ map the page
     1E00 ,         \    0 SBZ,            \ card off
                    \ ENDIF,
     0204 , PMEM ,  \ TOS PMEM LI,         \ page_mem->tos
     A105 ,         \ R5  TOS ADD,         \ add computed offset to page
     NEXT,
     ENDCODE

\ paged memory fetch and store
\ : C@P    ( addr -- n)    PAGED C@ ;   \ fetch a byte
\ : C!P    ( n addr -- )   PAGED C! ;   \ store a byte
\ : @P     ( addr -- n)    PAGED @ ;    \ fetch an int
\ : !P     ( n 32addr -- ) PAGED ! ;    \ store an int

CR HERE SWAP - DECIMAL . .( bytes)
SAMS-OFF SAMSINI SAMS-ON
1 SEGMENT
CR .( SAMS card activated)
CR .( Window = ) PMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR
