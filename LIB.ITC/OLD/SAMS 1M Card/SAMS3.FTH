\ SAMS CARD support. 64K segmented memory fetch and store
\ NEEDS DUMP  FROM DSK1.TOOLS  \ debugging only
NEEDS MOV, FROM DSK1.ASM9900

HERE
HEX
     VARIABLE BANK#      \ current mapped bank
1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT PMEM       \ paged memory block location
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

CODE PAGED  ( addr -- offset bank# )
        R0  4K LI,      \ 4K divisor ->R0
        TOS PUSH,       \ address to stack
        SEG @@ TOS MOV, \ segment to TOS
        R0 TOS DIV,     \ unsigned division
        TOS BANK# @@ CMP,
        EQ IF,
         ( *THE MAPPER* )
           TOS BANK# @@ MOV,
           TOS SWPB,
           R12 1E00 LI,
           0 SBO,
           TOS 4006 @@ MOV,
           0 SBZ,
       ENDIF,
       TOS POP,
       TOS PMEM AI,
       NEXT,
       ENDCODE

\ paged memory fetch and store
: C@P    ( addr -- n)    PAGED C@ ;   \ fetch a byte
: C!P    ( n 32addr -- ) PAGED C! ;   \ store a byte
: @P     ( 32addr -- n)  PAGED @ ;    \ fetch an int
: !P     ( n 32addr -- ) PAGED ! ;    \ store an int

SAMSINI
CR .( SAMS card initialized)
CR HERE SWAP - DECIMAL . .( bytes) HEX
