
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

\ This version is only marginally faster than using DIV above
     HEX
     CREATE _D>REAL  ( 32bit-address -- paged_address )
          TOS   4 SLA,   \ 28
         *SP   R5 MOV,   \ 18   \ dup
          R5   0C SRL,   \ 36
          R5  TOS ADD,   \ 14   \ create page# in TOS
          R0 F000 LI,    \ 14
          R0  *SP SZC,   \ 18  \ create offset in *SP
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
          *SP+ TOS ADD,        \ add computed offset to page
          RT,


     CODE >REAL   ( d -- addr) _32>REAL  @@ BL,   NEXT, ENDCODE
     CODE >REAL2  ( d -- addr) _32>REAL2 @@ BL,   NEXT, ENDCODE

     : TESTDIV  TMR@  ABCD F >REAL TMR@  NIP - . ;
     : TESTSLA  TMR@  ABCD F >REAL2 TMR@ NIP - . ;
