\ SAMS CARD support for CAMEL99 Forth   May 2020  B Fox
\ Uses a 32bit continuous address
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
         DUP 01 20 WITHIN 0= ABORT" SAMS segment err"
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
           0100 +        \ next value
       2 +LOOP
       0SBZ              \ turn off card
       DROP
;
HEX
: DPAGED  ( 32bitaddr -- addr')
         SEG @ +         \ skip first 64K of SAMS
         1000 UM/MOD    ( -- offset bank#)
         DUP BANK# @ =      \ are we using the same PAGE
         IF
             DROP           \ Yes! Drop bank# and get out
         ELSE
             DUP BANK# !    \ update bank# variable
             ><             \ swap bytes, bank# must be in left byte
            SAMSCARD 0SBO   \ turn on the card
          ( bank#) SREG !   \ store bank in SAMS register
            0SBZ            \ turn off card
         THEN  PMEM +       \ then add offset to paged mem block
;

\ paged memory fetch and store
: C@P    ( 32addr -- n)  DPAGED C@ ;   \ fetch a byte
: C!P    ( n 32addr -- ) DPAGED C! ;   \ store a byte
: @P     ( 32addr -- n)  DPAGED @ ;    \ fetch an int
: !P     ( n 32addr -- ) DPAGED ! ;    \ store an int

SAMS-OFF SAMSINI SAMS-ON
CR .( SAMS card activated)
CR HERE SWAP - DECIMAL . .( bytes)
