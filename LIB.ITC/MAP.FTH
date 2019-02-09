\ CAMEL99 SAMS card support
HEX
 INCLUDE DSK1.TOOLS  \ debugging
 INCLUDE DSK1.ASM9900

HEX
\ translated from TurboForth
 CODE MAP ( bank addr -- )
         0244 , F000 ,   \ TOS F000 ANDI, \ set to 4k boundary
         09B4 ,          \ TOS   0B SRL,  \ divide by 2048
         0224 , 4000 ,   \ TOS 4000 AI,   \ convert to SAMS register address
         C0B6 ,          \ *SP+  R2 MOV,  \ get bank
         0242 , 00FF ,   \ R2    FF ANDI, \ mask off any crap
         C002 ,          \ R2    R0 MOV,  \ keep a copy
         0A82 ,          \ R0    R2 XOR,  \ combine r0 & r2. Hi & lo bytes are now identical
         2880 ,          \ R2    08 SLA,  \ move to high byte
         020C , 1E00 ,   \ R12 1E00 LI,   \ cru address of SAMS
         1D00 ,          \       0 SBO,   \ enable SAMS card
         C502 ,          \ R2  *TOS MOV,  \ poke sams register
         1E00 ,          \        0 SBZ,  \ disable sams card
         C136 ,          \      TOS POP,
         NEXT,
         ENDCODE

CODE CRU!   C304 ,  C136 ,  NEXT, ENDCODE
CODE 0SBO   1D00 ,  NEXT, ENDCODE
CODE 0SBZ   1E00 ,  NEXT, ENDCODE

\ Translation of same word Forth 3.5 x slower
 : MAP2  ( bank# addr -- ) \ ASM converted to Forth
         F000 AND                    \ only need 4 bits
         0B RSHIFT                   \ divide by 2048
         4000 +                      \ convert to SAMS register address
         SWAP \ 00FF AND               \ mask to get a byte
         DUP FUSE                    \ Hi & lo bytes are now identical
         SWAP                       ( -- bank_addr samsregister)
         1E00 CRU!                   \ select SAMS card
         0SBO                        \ enable SAMS card
         !                           \ store bank in SAMS register
         0SBZ ;                      \ disable SAMS card

\ Assumes paged mem is constant location Forth ~1/4 speed
 3000 CONSTANT PAGEMEM

 : MAP3  ( bank# -- ) \ ~1/2 SPEED
\         F000 AND                   \ set the constant correctly :-)
[ PAGEMEM 0B RSHIFT 4000 + ] LITERAL \ compute SAMS register at compile time
         SWAP 00FF AND               \ mask to get a byte
         DUP FUSE                    \ Hi & lo bytes are now identical
         SWAP                       ( -- bank_addr samsregister)
         1E00 CRU!                   \ select SAMS card
         0SBO                        \ enable SAMS card
         !                           \ store bank in SAMS register
         0SBZ ;                      \ disable SAMS card

CODE (MAP) 
        *SP+   R2 MOV,  \ get bank
         R2    FF ANDI, \ mask off any crap
         R2    R0 MOV,  \ keep a copy
         R0    R2 XOR,  \ combine r0 & r2. Hi & lo bytes are now identical
         R2    08 SLA,  \ move to high byte
         R12 1E00 LI,   \ cru address of SAMS
         0 SBO,         \ enable SAMS card
         R2  *TOS MOV,  \ poke sams register
         0 SBZ,         \ disable sams card
         TOS POP,
         NEXT,
         ENDCODE

 : MAP4 ( bank# -- ) \ forth tricks and ASM code
        [ PAGEMEM 0B RSHIFT 4000 + ] LITERAL \ compute at compile time
         (MAP) ;

CODE MAP3000 ( bank# -- )
         R0 4006 LI,    \ SAMS register for >3000
         TOS


: TEST1  TMR@  5 6000 MAP TMR@ - ABS . ;  \  298uS
: TEST2  TMR@  5 6000 MAP2 TMR@ - ABS . ; \ 1022uS
: TEST3  TMR@  5 MAP3 TMR@ - ABS . ;      \  746uS
: TEST4  TMR@  5 MAP4 TMR@ - ABS . ;      \  340uS



\ paging takes place in cartridge space at >6000
 : CHANGEPAGE
         100 0
         DO
            I PAGEMEM MAP
         LOOP
         2 PAGEMEM MAP ;  \ return to default value
         
: BLOCK  ( n -- addr )  PAGEMEM MAP PAGEMEM ;
