\ SAMS CARD support for CAMEL99 Forth         May 2020  B Fox
\ Written in Forth so you can see how it works
\ see: SAMSFAST32 for Assembler version. 2X faster
\ INCLUDE DSK1.TOOLS

NEEDS SAMSINI FROM DSK1.SAMSINI
HERE
HEX
  3000 CONSTANT PMEM  \ paged memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

VARIABLE BANK#      \ current mapped bank

HEX
: DPAGED  ( 32bitaddr -- addr')
         1000 UM/MOD ( -- offset bank#)
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

\ "long" memory fetch and store uses 32bit address.
: C@L    ( 32addr -- n)  DPAGED C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) DPAGED C! ;   \ store a byte
: @L     ( 32addr -- n)  DPAGED @ ;    \ fetch an int
: !L     ( n 32addr -- ) DPAGED ! ;    \ store an int
CR HERE SWAP - DECIMAL . .( bytes)

SAMS-OFF SAMSINI SAMS-ON
CR .( SAMS card activated)

HEX
\ test code
\ : STORESAMS     FFFF 0 DO     I  I 1 !L       2 +LOOP ; \ 32.8 secs
\ : FETCHSAMS     FFFF 0 DO        I 1 @L DROP  2 +LOOP ; \ 31.3 secs

\ regular ram comparison
\ : FETCHRAM      FFFF 0 DO    I @  DROP        2 +LOOP ; \  8 secs
