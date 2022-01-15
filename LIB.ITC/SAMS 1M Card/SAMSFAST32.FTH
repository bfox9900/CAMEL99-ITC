\ SAMS CARD support. 64K segmented memory fetch and store

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

     VARIABLE SEG        \ holds current 64K segment

\ safely set the 64K segment that you want to use
: SEGMENT ( 1..F -- )
       DUP 01 10 WITHIN 0= ABORT" BAD segment selected"
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
CREATE _PAGED  ( addr -- paged_address )
     R0  4K LI,         \ 4K divisor ->R0
     TOS R5 MOV,        \ address to r5
     SEG @@ TOS MOV,    \ segment# to R4,
     R0 TOS DIV,        \ TOS=bank#, R5=offset
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

CODE PAGED ( SEGaddr -- CPUaddress )   _PAGED @@ BL,  NEXT, ENDCODE

CODE @L    ( SEGaddr -- n)
    _PAGED @@ BL,
    *TOS  TOS MOV,
    NEXT,
ENDCODE


CODE !L    ( n SEGadd -- )
    _PAGED @@ BL,
    *SP+ *TOS MOV,
    TOS POP,
    NEXT,
ENDCODE

\ paged memory fetch and store
\ : @L     ( addr -- n)    PAGED @ ;    \ fetch an int
\ : !L     ( n 32addr -- ) PAGED ! ;    \ store an int
: C@L    ( addr -- n)    PAGED C@ ;   \ fetch a byte
: C!L    ( n addr -- )   PAGED C! ;   \ store a byte

\ SAMSINI  (only on real iron)
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes)  \  314 BYTES

HEX
\ test code
1 SEGMENT
 : LOADSAMS     FFFF 0 DO   I  I !L        2 +LOOP ; \ 13 secs
 : READSAMS     FFFF 0 DO    I @L DROP     2 +LOOP ; \ 11 secs
 : READRAM      FFFF 0 DO    I @ DROP      2 +LOOP ; \  8 secs  
