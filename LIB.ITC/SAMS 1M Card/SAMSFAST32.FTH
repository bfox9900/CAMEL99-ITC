\ SAMS CARD using 32bit contiguous address   Jan  15 2022  Brian Fox

\ 1 sams page only.  Set to >3000 by PMEM (paged memory)

 NEEDS DUMP  FROM DSK1.TOOLS
 NEEDS MOV,  FROM DSK1.ASM9900
 NEEDS ELAPSE  FROM DSK1.ELAPSE

 NEEDS SAMSINI FROM DSK1.SAMSINI  \ common code for SAMS card

HERE
HEX
     VARIABLE BANK#      \ current mapped bank

1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT PMEM       \ paged memory block location
PMEM 0B RSHIFT 4000 + CONSTANT SREG

HEX
CREATE VIRT>REAL  ( 32bit-address -- paged_address )
     R0  4K LI,            \ 4K divisor ->R0         12
     R5    POP,            \ address to r5           28
     R0 TOS DIV,           \ TOS=bank#, R5=offset   124
     TOS BANK# @@ CMP,     \ switch page ?
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

CODE @L  ( d -- n)
    VIRT>REAL @@ BL,
    *TOS  TOS MOV,
    NEXT,
ENDCODE

CODE !L  ( n d -- )
    VIRT>REAL @@ BL,
    *SP+ *TOS MOV,
    TOS POP,
    NEXT,
ENDCODE

SAMSINI
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes)

HEX
\ test code
\ : STORESAMS     FFFF 0 DO     I  I 1 !L       2 +LOOP ; \ 14.5 secs
\ : FETCHSAMS     FFFF 0 DO        I 1 @L DROP  2 +LOOP ; \ 13.2 secs

\ regular ram comparison
\ : FETCHRAM      FFFF 0 DO    I @  DROP        2 +LOOP ; \  8 secs
