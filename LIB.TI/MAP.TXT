\ CAMEL99 SAMS card support
HEX
\ translated from TurboForth
\ CODE: MAP ( bank addr -- )
\       TOS F000 ANDI,       \ set to 4k boundary
\       TOS   0B SRL,        \ divide by 2048
\       TOS 4000 ADDI,       \ convert to SAMS register address
\      *SP+   R2 MOV,        \ get bank
\       R2    FF ANDI,       \ mask off any crap
\       R2    R0 MOV,        \ keep a copy
\       R2    08 SLA,        \ move to high byte
\       R0    R2 XOR,        \ combine r0 & r2. Hi & lo bytes are now identical
\       R12 1E00 LI,         \ cru address of SAMS
\       0 SBO,               \ enable SAMS registers
\       R2  *TOS MOV,        \ poke sams register
\       0 SBZ,               \ disable sams registers
\       NEXT,
\       END-CODE

\ Forth translation of same word in TurboForth
: MAP  ( bank addr -- ) \ ASM converted to Forth
         F000 AND  0B RSHIFT 4000 +
         SWAP 00FF AND  DUP >< OR   \ Hi & lo bytes are now identical
         SWAP ( -- bank address)
         1E00 CRU! SBO              \ enable SAMS card
         !                          \ store bank in SAMS register
         SBZ ;                      \ disable SAMS card

\ test code writes 2 strings to each page.
\ paging takes place in lower 4K of Low mem
2000 CONSTANT $2000

: >STR    ( n -- addr len )  0 <# #S #>  ;
: .STR    ( addr len -- ) COUNT TYPE ;

: FILLMAP
         20 0 DO
         100 10
          DO
             I $2000 MAP
\             S" *PAGE*" $2000 PLACE
\             I >STR 2008 PLACE
          LOOP
         LOOP
          2 $2000 MAP ;  \ return to default value
: SEEAMS
         100 10
          DO
             I $2000 MAP
             CR 2000 .STR  SPACE 2008 .STR
          LOOP
          2 $2000 MAP ;  \ return to default value
