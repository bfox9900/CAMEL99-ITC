\ SAMS CARD support for TI-FORTH   Oct 2020  B Fox
\ Inits SAMS to pass through memory pages

HERE

HEX
: CELLS  1 SLA ;

8300 0C CELLS + CONSTANT 'R12   \ workspace=>8300

\ *** SET DMEM TO YOUR RAM PAGE ***
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

D000 CONSTANT DMEM    \ CPU RAM memory block location
0020 CONSTANT #REGS   \ # sams Registers, ie: size of card >20 is 1Mbyte
   0 VARIABLE SEG     \ holds current 64K segment
   0 VARIABLE BANK#   \ current mapped bank

\ using machine code so we don't need the CRU library
HEX
\ *set the CRU address in 'R12 before using these words*
  CODE 0SBO ( -- ) 1D00 ,  NEXT,
  CODE 0SBZ ( -- ) 1E00 ,  NEXT,
  CODE 1SBO ( -- ) 1D01 ,  NEXT,
  CODE 1SBZ ( -- ) 1E01 ,  NEXT,

: SAMSCARD  ( -- ) 1E00 'R12 ! ;    \ select sams card
: SAMS-ON   ( -- ) SAMSCARD 0SBO ;  \ enable card
: SAMS-OFF  ( -- ) SAMSCARD 0SBZ ;  \ disable card
: MAP-ON    ( -- ) SAMSCARD 1SBO ;  \ enable mapper
: MAP-OFF   ( -- ) SAMSCARD 1SBZ ;  \ disable mapper


\ These are arrays of sams registers values for TI-FORTH pass thru
\ 1ST                2nd     3rd   4th    etc.
0202 VARIABLE LOSAMS 0303 ,
0A0A VARIABLE HISAMS 0B0B , 0C0C , 0D0D , 0E0E , 0F0F ,

: SAMSINI
      SAMS-ON
      LOSAMS 4004  2 CELLS CMOVE    \ load low ram registers
      HISAMS 4014  6 CELLS CMOVE    \ load hi ram registers
      SAMS-OFF
;

: DMAP ( bank# -- )   \ map a DATA page at DMEM address
      DUP BANK# !     \ remember the bank#
      SWPB            \ swap bytes, bank# must be in left byte
      SAMSCARD 0SBO   \ turn on the card
    ( bank#)
\ compute the SAMS card register based on DMEM at compile time for speed
    [ 4000  DMEM 0B SRL + ] LITERAL ! \ store bank in SAMS register
      0SBZ            \ turn off card
;

CR HERE SWAP - DECIMAL .

SAMSINI MAP-ON
CR ." SAMS card activated"
 
