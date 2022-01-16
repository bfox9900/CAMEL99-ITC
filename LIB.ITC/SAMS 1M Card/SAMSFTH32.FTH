\ SAMS CARD support for CAMEL99 Forth   May 2020  B Fox
\ Uses a 32bit continuous address
\
HERE

DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
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

: SAMS-OFF  ( --) 1E00 'R12 !  1SBZ ;  \ disable mapper
: SAMS-ON   ( --) 1E00 'R12 !  1SBO ;  \ enable mapper

\ * SAMSINI sets card to "power-up" condition
: SAMSINI
       1E00 'R12 !          \ select SAMS card CRU address
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
: SAMS>REAL  ( 32bitaddr -- addr')
         1000 UM/MOD    ( -- offset bank#)
         DUP BANK# @ =      \ are we using the same PAGE
         IF  DROP ELSE
             DUP BANK# !    \ update bank# variable
             ><             \ swap bytes, bank# must be in left byte
            1E00 'R12 ! 0SBO   \ turn on the card
           ( bank#) SREG !   \ store bank in SAMS register
             0SBZ            \ turn off card
         THEN PMEM +       \ then add offset to paged mem block
;

\ paged memory fetch and store
: C@L    ( 32addr -- n)  SAMS>REAL C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) SAMS>REAL C! ;   \ store a byte
: @L     ( 32addr -- n)  SAMS>REAL @ ;    \ fetch an int
: !L     ( n 32addr -- ) SAMS>REAL ! ;    \ store an int

\  SAMSINI  DO NOT USE ON Classi99 emulator
SAMS-ON
CR .( SAMS card activated)
CR HERE SWAP - DECIMAL . .( bytes)

1 SEG !  \ set the segment

: WRITE64  -1  0 DO   I  I  SEG @ !L  LOOP ;
