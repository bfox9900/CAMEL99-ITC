\ SAMS CARD support. 64K segmented memory fetch and store
\ NEEDS DUMP  FROM DSK1.TOOLS  \ debugging only
HERE
 NEEDS SBO   FROM DSK1.CRU2

HEX
     VARIABLE BANK#      \ current mapped bank
1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT PMEM       \ paged memory block location
     VARIABLE SEG        \ holds current 64K segment

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
          DUP 01 10 WITHIN 0= ABORT" BAD segment selected"
          SEG ! ;  \ don't allow segment 0

1 SEGMENT

: SAMS-OFF ( --) 1E00 CRU! 1 SBZ ;
: SAMS-ON  ( --) 1E00 CRU! 1 SBO ;

\ * SAMSINI sets card to "power-up" condition
: SAMSINI
       1E00 CRU! 0SBO    \ turn on card
       0                 \ 1st value
       4000 20           \ register address, #regs
       BOUNDS
       DO
           DUP I !       \ I is reg. address
           0101 +        \ next value
       2 +LOOP
       0SBZ              \ turn off card
       DROP
;

: PAGED  ( addr -- addr')
         SEG @ 4K UM/MOD  ( -- offset bank#)
         DUP BANK# @ =            \ are we using the same PAGE
         IF
             DROP                 \ Yes! Drop bank# and get out
         ELSE
             DUP FF00 AND ABORT" SAMS Err!"
             DUP BANK# !           \ update bank# variable
             ><                    \ swap bytes, bank# must be in left byte
            1E00 CRU! 0SBO         \ enable SAMS card
           ( bank#) 4006 !         \ store bank in 3K SAMS register
             0SBZ                  \ disable SAMS card

        THEN  PMEM +               \ then add offset to paged mem block
;

\ paged memory fetch and store
: C@P    ( addr -- n)    PAGED C@ ;   \ fetch a byte
: C!P    ( n 32addr -- ) PAGED C! ;   \ store a byte

: @P     ( 32addr -- n)  PAGED @ ;    \ fetch an int
: !P     ( n 32addr -- ) PAGED ! ;    \ store an int

SAMSINI
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes) HEX
         
