\ SAMS CARD support. 64K segmented memory fetch and store

\ 1 sams page only.  Set to >3000 by PMEM (paged memory)

\ ******************************************************
\ *** RUN SAMSINI before using the card ON REAL TI99 ***
\ ******************************************************

\ NEEDS DUMP  FROM DSK1.TOOLS  \ debugging only

HERE
HEX
     VARIABLE BANK#      \ current mapped bank
\ 1000 CONSTANT 4K         \ bytes per bank = 4K
     VARIABLE SEG        \ holds current 64K segment

3000 CONSTANT DMEM       \ paged memory block location
\ compute SAMS register based on PMEM address
PMEM 0B RSHIFT 4000 + CONSTANT SREG

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
       DUP 01 10 WITHIN 0= ABORT" SAMS segment err"
       SEG ! ;  \ don't allow segment 0

1 SEGMENT

\ using machine code so we don't need the CRU library
CODE SAMS-OFF  ( --) \ disable mapped memory
       020C , 1E00 , \ R12 1E00 LI,
       1E01 ,        \ 1 SBZ,
       NEXT,
       ENDCODE

CODE SAMS-ON ( -- )  \ enable mapped memory
       020C , 1E00 , \ R12 1E00 LI,
       1D01 ,        \ 1 SBO,
       NEXT,
       ENDCODE

\ * AMSINI sets ams card to "power-up" condition
CODE SAMSINI
       020C , 1E00 , \ R12 1E00 LI,
       1D00 ,        \ 0 SBO,       ( turn on Sams card )
       04C1 ,        \ R1 CLR,
       0200 , 4000 , \ R0 4000 LI,  ( CARD memory)
                     \ BEGIN,
       CC01 ,        \ R1 R0 *+ MOV, ( move to mem-mapper)
       0221 , 0101 , \ R1 0101  AI, ( add 1 page)
       0280 , 4020 , \ R0 4020 CI,  ( all done? )
       16FA ,        \ EQ UNTIL,    ( no, init more)
       1E00 ,        \ 0 SBZ,       ( turn off SAMS card)
       NEXT,         \ return
       ENDCODE
HEX
CODE DMAP  ( page# -- paged_address )
     8804 , BANK# , \ TOS BANK# @@ CMP,  \ switch page ?
     1309 ,         \ NE IF,
     C804 , BANK# , \    TOS BANK# @@ MOV, \ YES, update BANK#
     06C4 ,         \    TOS SWPB,
     020C , 1E00 ,  \    R12 1E00 LI,      \ select SAMS
     1D00 ,         \    0 SBO,            \ card on
     C804 , SREG ,  \    TOS 4006 @@ MOV,  \ map the page
     1E00 ,         \    0 SBZ,            \ card off
                    \ ENDIF,
     0204 , DMEM ,  \ TOS PMEM LI,         \ page_mem->tos
     A105 ,         \ R5  TOS ADD,         \ add computed offset to page
     NEXT,
     ENDCODE

\ SAMSINI  SAMS-ON ( only on real iron)
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes)  \  314 BYTES
