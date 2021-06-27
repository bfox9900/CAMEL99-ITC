\ SAMS CARD support for CAMEL99 Forth   May 2020  B Fox
\ 64K segmented memory fetch and store
\
HERE

DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
: SAMSCARD  ( -- ) 1E00 'R12 ! ;   \ select sams card

  3000 CONSTANT PMEM  \ paged memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

     VARIABLE SEG        \ holds current 64K segment
     VARIABLE BANK#      \ current mapped bank
\ using machine code so we don't need the CRU library
HEX
\ *set the CRU address in 'R12 before using these words*
 CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
 CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE

 CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
 CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE

: SAMS-OFF  ( --) SAMSCARD 1SBZ ;  \ disable mapper
: SAMS-ON   ( --) SAMSCARD 1SBO ;  \ enable mapper

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
         DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;  \ don't allow segment 0
 1 SEGMENT

\ * SAMSINI sets card to "power-up" condition
: SAMSINI
       SAMSCARD          \ select SAMS card CRU address
       0SBO              \ turn card on
       0                 \ 1st value
       4000 20           \ register address, # SAMS regs
       BOUNDS ( -- 4020 4000 )
       DO
           DUP I !       \ I is reg. address
           I @ OVER <> ABORT" SAMS Init err"
           0101 +        \ next value
       2 +LOOP
       0SBZ              \ turn off card
       DROP
;

HEX
: PAGED  ( addr -- addr')
         DUP 0FFF AND
         OVER 0C RSHIFT 10 +   ( -- offset bank#)
         DUP BANK# @ =      \ are we using the same PAGE
         IF
             DROP           \ Yes! Drop bank# and get out
         ELSE
             DUP BANK# !    \ update bank# variable
             ><
             SAMSCARD 0SBO  \ turn on the card
             SREG !         \ store bank# in SAMS register
             0SBZ           \ turn off card
         THEN  PMEM +       \ then add offset to paged mem block
;

\ paged memory fetch and store
: C@P    ( addr -- n)    PAGED C@ ;   \ fetch a byte
: C!P    ( n 32addr -- ) PAGED C! ;   \ store a byte

: @P     ( 32addr -- n)  PAGED @ ;    \ fetch an int
: !P     ( n 32addr -- ) PAGED ! ;    \ store an int

\ SAMSINI SAMS-ON   ( un-comment for real iron)
CR .( SAMS card activated)
CR HERE SWAP - DECIMAL . .( bytes)
