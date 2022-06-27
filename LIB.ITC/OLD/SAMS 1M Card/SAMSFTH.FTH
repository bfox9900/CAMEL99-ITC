\ SAMS CARD support for CAMEL99 Forth   May 2020  B Fox
\ 64K segmented memory model for DATA
\
HERE
DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
: SAMSCARD  ( -- ) 1E00 'R12 ! ;   \ select sams card

3000 CONSTANT DMEM    \ CPU RAM memory block location
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

     VARIABLE SEG     \ holds current 64K segment
     VARIABLE BANK#   \ current mapped bank

\ using machine code so we don't need the CRU library
HEX
\ *set the CRU address in 'R12 before using these words*
  CODE 0SBO  ( -- ) 1D00 ,  NEXT, ENDCODE
  CODE 0SBZ  ( -- ) 1E00 ,  NEXT, ENDCODE
  CODE 1SBO  ( -- ) 1D01 ,  NEXT, ENDCODE
  CODE 1SBZ  ( -- ) 1E01 ,  NEXT, ENDCODE

: SAMS-ON   ( -- ) SAMSCARD 1SBO ;  \ enable mapper
: SAMS-OFF  ( -- ) SAMSCARD 1SBZ ;  \ disable mapper

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- ) \ don't allow segment 0
         DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;
 1 SEGMENT

\ * SAMSINI sets card to "power-up" condition
: SAMSINI
       1E00 'R12 !       \ select SAMS card CRU address
       0SBO              \ turn card on
       0                 \ 1st value
       4000 20           \ register address, # SAMS regs
       BOUNDS ( -- 4100 4000)
       DO
           DUP I !       \ I is reg. address
           I @ OVER <> ABORT" SAMSINI err"
           0100 +        \ next value 0101 for 1MB card, 0100 Classic99
       2 +LOOP
       0SBZ              \ turn off card
       DROP
;

: DMAP ( bank# -- )   \ map a DATA page at PMEM address
      DUP BANK# !
      ><              \ swap bytes, bank# must be in left byte
      SAMSCARD 0SBO   \ turn on the card
    ( bank#)
\ compute the SAMS card register based on DMEM at compile time
    [ 4000  DMEM 0B RSHIFT + ] LITERAL ! \ store bank in SAMS register
      0SBZ            \ turn off card
;
HEX
: PAGED  ( virtual-addr -- real-addr)
      SEG @ 1000 UM/MOD  ( -- offset bank#)
      DUP BANK# @ -     \ different page?
      IF   DMAP
      ELSE DROP
      THEN DMEM +       \ then add offset to paged mem block
;

CR HERE SWAP - DECIMAL . .( bytes)

SAMS-OFF SAMSINI SAMS-ON
CR .( SAMS card activated)
