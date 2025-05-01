CR .( SAMS CARD for CAMEL99 in FORTH,  Oct 2024 B Fox)
\ 64K byte segmented memory model for DATA
\ You can access any ADDRESS from 0 to 65535 using VIRT>REAL

\ Jan 2023 SIMPLIFIED MAP for maximum speed 
NEEDS SAMSINI  FROM DSK1.SAMSINI  \ common code all SAMS libraries

HERE
VARIABLE SEG     \ holds current 64K segment
VARIABLE BANK#   \ current mapped bank

HEX
3000 CONSTANT PMEM    \ CPU RAM "PAGE" memory location
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

\ map takes a 32bit address, which can also be viewed as (offset,page#)
HEX 
: DMAP ( d -- )  \ -or-  ( offset page# -- )
      BANK# @ OVER= IF  DROP PMEM + EXIT  THEN \ page is in memory 
      DUP BANK# !
      1E00 'R12 !     \ 'R12 defined in DSK1.SAMSINI
      0SBO            \ enable registers
      DUP FUSE SREG ! 
\      >< SREG !       \ swap bytes & store in SAMS register
      0SBZ            \ card off
      PMEM +          \ then add offset to paged mem block
;

HEX
: VIRT>REAL ( virtual-addr -- real-addr) SEG @ 1000 UM/MOD  DMAP ;

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- ) \ don't allow segment 0
      DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
      SEG ! ;

\ VIRT>REAL memory fetch and store from SAMS segment
: !L   ( n Virtaddr -- ) S" VIRT>REAL !" EVALUATE ; IMMEDIATE
: @L   ( Virtaddr -- n)  S" VIRT>REAL @" EVALUATE ; IMMEDIATE
: C!L  ( n Virtaddr -- ) S" VIRT>REAL C!" EVALUATE ; IMMEDIATE 
: C@L  ( Virtaddr -- n)  S" VIRT>REAL C@" EVALUATE ; IMMEDIATE

CR HERE SWAP - DECIMAL . .( bytes)

SAMS-OFF SAMSINI SAMS-ON

1 SEGMENT
CR .( SAMS card activated)
CR .( Window = >) PMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR

DECIMAL
\ : TEST     FFFF 0 DO  I I !L  2 +LOOP ; \ 31.21 seconds 
\ : TEST3   400 0 DO  10 DMAP 20 DMAP LOOP ; \ MISS: 0.73 sec. ~1400/SEC
\ : TEST4   400 0 DO  10 DMAP 10 DMAP LOOP ; \ HIT:  0.36 sec. ~2400/SEC

