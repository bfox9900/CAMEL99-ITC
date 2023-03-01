\ SAMS CARD support for CAMEL99 in Forth   May 2020  B Fox
\ 16 by 64K segmented memory model for DATA
\ You can access any ADDRESS from 1 to 65535 using PAGED
\ Jan 2023 SIMPLIFIED MAP for maximum speed 
NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
VARIABLE SEG     \ holds current 64K segment
VARIABLE BANK#   \ current mapped bank
HEX
3000 CONSTANT DMEM    \ CPU RAM memory block location
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

\ compute SAMS register based on DMEM address
DMEM 0B RSHIFT 4000 + CONSTANT DREG

\ map takes a 32bit address, which can also be viewed as (offset,page#)
HEX 
: DMAP ( d -- )  \ -or-  ( offset page# -- )
      BANK# @ OVER=     \ same page?
      IF DROP DMEM + EXIT THEN
      DUP BANK# !
      1E00 'R12 !
      0SBO            \ enable registers
      >< DREG !       \ swap bytes & store in SAMS register
      0SBZ            \ card off
      DMEM +          \ then add offset to paged mem block
;


HEX
: PAGED  ( virtual-addr -- real-addr)
      SEG @ 1000 UM/MOD ( -- offset bank#) DMAP ;

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- ) \ don't allow segment 0
      DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
      SEG ! ;

CR HERE SWAP - DECIMAL . .( bytes)
SAMS-OFF SAMSINI SAMS-ON

1 SEGMENT
CR .( SAMS card activated)
CR .( Window = >) DMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR


: !L  ( 32bit -- ) PAGED !   ;

HEX
: TEST  
   FFFF 0 
   DO 
     [CHAR] #  I !L
   LOOP ; \ 63 seconds 

: TEST3   400 0 DO  10 DMAP 20 DMAP LOOP ; \ MISS: 0.73 sec. ~1400/SEC
: TEST4   400 0 DO  10 DMAP 10 DMAP LOOP ; \ HIT:  0.36 sec. ~2400/SEC

