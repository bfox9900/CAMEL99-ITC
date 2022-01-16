\ SAMS CARD using 32bit contiguous address   Jan  15 2022  Brian Fox 

\ 1 sams page only.  Set to >3000 by PMEM (paged memory)

\ ******************************************************
\ *** RUN SAMSINI before using the card ON REAL TI99 ***
\ ******************************************************

 NEEDS DUMP  FROM DSK1.TOOLS  \ debugging only
 NEEDS MOV,  FROM DSK1.ASM9900
 NEEDS ELAPSE  FROM DSK1.ELAPSE

HERE
HEX
     VARIABLE BANK#      \ current mapped bank

1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT PMEM       \ paged memory block location
PMEM 0B RSHIFT 4000 + CONSTANT SREG

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

HEX
CREATE _D>REAL  ( 32bit-address -- paged_address )
     R0  4K LI,         \ 4K divisor ->R0         12
     R5    POP,         \ address to r5           28
     R0 TOS DIV,        \ TOS=bank#, R5=offset   124
     TOS BANK# @@ CMP,  \ switch page ?
     NE IF,
         TOS BANK# @@ MOV, \ YES, update BANK#
         TOS SWPB,
         R12 1E00 LI,      \ select SAMS
         0 SBO,            \ card on
         TOS 4006 @@ MOV,  \ map the page
         0 SBZ,            \ card off
     ENDIF,
     TOS PMEM LI,         \ page_mem->tos
     R5  TOS ADD,         \ add computed offset to page
     RT,

CODE @L    ( d -- n)
    _D>REAL @@ BL,
    *TOS  TOS MOV,
    NEXT,
ENDCODE

CODE !L    ( n d -- )
    _D>REAL @@ BL,
    *SP+ *TOS MOV,
    TOS POP,
    NEXT,
ENDCODE

\ SAMSINI  (only on real iron)
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes)    \ 314 bytes

HEX
\ test code
: STORESAMS     FFFF 0 DO     I  I 1 !L       2 +LOOP ; \ 14.5 secs
: FETCHSAMS     FFFF 0 DO     I 1 @L DROP     2 +LOOP ; \ 13.2 secs

\ REGULAR RAM COMPARISON
: FETCHRAM      FFFF 0 DO    I @  DROP     2 +LOOP ; \  8 secs
