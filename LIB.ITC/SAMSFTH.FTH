\ SAMS CARD support for CAMEL99 in Forth   May 2020  B Fox
\ 16 by 64K segmented memory model for DATA
\ You can access any ADDRESS from 1 to 65535 using PAGED
NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
VARIABLE SEG     \ holds current 64K segment
VARIABLE BANK#   \ current mapped bank
HEX
3000 CONSTANT DMEM    \ CPU RAM memory block location
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

\ compute SAMS register based on DMEM address
DMEM 0B RSHIFT 4000 + CONSTANT DREG

HEX
: PAGED  ( virtual-addr -- real-addr)
      SEG @ 1000 UM/MOD  ( -- offset bank#)
      DUP BANK# @ -     \ different page?
      IF
        DUP BANK# !
        SAMSCARD 0SBO   \ card on, enable registers
( bank#) >< DREG !      \ swap bytes & store in SAMS register
         0SBZ           \ card off
      ELSE DROP
      THEN DMEM +       \ then add offset to paged mem block
;
\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- ) \ don't allow segment 0
      DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
      SEG ! ;

CR HERE SWAP - DECIMAL . .( bytes)
SAMS-OFF SAMSINI SAMS-ON
1 SEGMENT
CR .( SAMS card activated)
CR .( Window = ) DMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR
