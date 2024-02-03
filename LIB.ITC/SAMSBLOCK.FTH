\ SAMSBLOCK lets you access any 4K page like a Forth BLOCK May 2020  B Fox
\ *VERY FAST*

\ NEEDS MOV,  FROM DSK1.LOWTOOLS

HERE
DECIMAL
  24 USER 'R12  \ address of R12 in any Forth workspace
HEX
: SAMSCARD  ( -- ) 1E00 'R12 ! ;   \ select sams card

3000 CONSTANT DMEM    \ "data memory" CPU RAM swapped memory location
\ Legal values: 2000,3000,A000,B000,C000,D000,E000,F000

DMEM 0B RSHIFT  4000 + CONSTANT SREG  \ SAMS register used for DMEM

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

\ * AMSINI sets ams card to "power-up" condition
CODE SAMSINI
     020C , 1E00 , \ R12 1E00 LI,
     1D00 ,        \ 0 SBO,       ( turn on Sams card )
     04C1 ,        \ R1 CLR,
     0200 , 4000 , \ R0 4000 LI,  ( CARD memory)
                   \ BEGIN,
     CC01 ,        \ R1 R0 *+ MOV, ( move to mem-mapper)
     0221 , 0100 , \ R1 0100  AI, ( add 1 page)
     0280 , 4020 , \ R0 4020 CI,  ( all done? )
     16FA ,        \ EQ UNTIL,    ( no, init more)
     1E00 ,        \ 0 SBZ,       ( turn off SAMS card)
     NEXT,         \ return
     ENDCODE

\ code version is fast and small
CODE SBLOCK ( bank# -- addr )
     8804 , BANK# ,   \ TOS BANK# @@ CMP,     \ same page ?
     1309 ,           \ NE IF,
     C804 , BANK# ,   \     TOS BANK# @@ MOV, \ no, update BANK#
     06C4 ,           \     TOS SWPB,
     020C , 1E00 ,    \     R12 1E00 LI,      \ select SAMS card
     1D00 ,           \     0 SBO,            \ card on
     C804 , SREG ,    \     TOS SREG @@ MOV,  \ map the page
     1E00 ,           \     0 SBZ,            \ card off
                      \ ENDIF,
     0204 , DMEM ,    \ TOS DMEM LI,          \ return DMEM address
     NEXT,
     ENDCODE

\ Forth version is 4X slower but can be used with multi-tasking
\ : SBLOCK2  ( bank# -- addr)
\         DUP BANK# @ = IF DMEM EXIT THEN
\         SAMSCARD 0SBO
\         DUP SREG ! BANK# !
\         0SBZ
\         DMEM ;

CR HERE SWAP - DECIMAL . .( bytes)

SAMSINI SAMS-ON
CR .( SAMS card activated)
