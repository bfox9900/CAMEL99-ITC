\ SAMS CARD support. 64K segmented memory fetch and store  2022 Brian Fox
\ 1 sams page only.  Set to >3000 by PMEM (paged memory)
\ This version is 2.7X faster than the version in SAMSFTH.Fth

NEEDS SAMSINI FROM DSK1.SAMSINI

HERE
HEX
     VARIABLE BANK#      \ current mapped bank
     VARIABLE SEG        \ holds current 64K segment

3000 CONSTANT PMEM       \ VIRT>REAL memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
       DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
       SEG ! ;  \ don't allow segment 0

1 SEGMENT

HEX
CODE VIRT>REAL  ( virtaddr -- real_address )
\ Lee Stewart's code to replace >1000 UM/MOD. 2.3% faster
     C020 , SEG ,   \ SEG @@ R0 MOV,    \ segment# to R0
     0A40 ,         \ R0 4 SLA,         \ page# segment starts
     C144 ,         \ R4 R5 MOV,        \ address to R5
     0245 , 0FFF ,  \ R5  0FFF ANDI,    \ page offset
     09C4 ,         \ R4 0C SRL,        \ page of current segment
     A100 ,         \ R0 R4 ADD,        \ bank#

     8804 , BANK# , \ R4 BANK# @@ CMP,    \ switch page ?
     1309 ,         \ NE IF,
     C804 , BANK# , \    R4 BANK# @@ MOV, \ YES, update BANK#
     06C4 ,         \    R4 SWPB,
     020C , 1E00 ,  \    R12 1E00 LI,      \ select SAMS
     1D00 ,         \    0 SBO,            \ card on
     C804 , SREG ,  \    R4 SREG @@ MOV,   \ map the page
     1E00 ,         \    0 SBZ,            \ card off
                    \ ENDIF,
     0204 , PMEM ,  \ R4 PMEM LI,         \ page_mem->tos
     A105 ,         \ R5  R4 ADD,         \ add computed offset to page

     NEXT, \ 46 bytes
     ENDCODE

\ VIRT>REAL memory fetch and store from SAMS segment
: !L   ( n Virtaddr -- ) VIRT>REAL   ! ;
: C!L  ( n Virtaddr -- ) VIRT>REAL  C! ;
: @L   ( Virtaddr -- n)  VIRT>REAL   @ ;
: C@L  ( Virtaddr -- n)  VIRT>REAL  C@ ;

CR HERE SWAP - DECIMAL . .( bytes)
SAMS-OFF SAMSINI SAMS-ON
1 SEGMENT

CR .( SAMS card activated)
CR .( Window = ) PMEM HEX U.
CR .( Segment = ) SEG @  DECIMAL U.
CR

\ HEX
\ : TEST     FFFF 0 DO  [CHAR] # I !L  LOOP ; \ Forth: 58.38 sec.
\                                             \ CODE : 21.05 sec.
