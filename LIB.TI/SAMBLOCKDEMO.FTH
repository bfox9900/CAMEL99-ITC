\ emulating Forth BLOCK in SAMS memory card (4K blocks)

NEEDS CRU! FROM DSK1.CRU

HEX
7FFF CONSTANT 32K
1000 CONSTANT 4K
  10 CONSTANT 1STBANK    \ avoid the lower 64K

4K  MALLOC CONSTANT PAGEMEM
\ Translation of ASM word in TurboForth. About 3.5 times slower
 : MAP  ( bank# addr -- )
         F000 AND         \ need even 4K boundary
         0B RSHIFT        \ divide by 2048
         4000 +           \ convert to SAMS register address
         SWAP 00FF AND    \ mask to get a byte
         DUP FUSE         \ Hi & lo bytes "fused" together
         SWAP             \  -- bank_addr samsregister
         1E00 CRU!        \ select SAMS card
         0SBO             \ enable SAMS card
       ( bank samsreg) !  \ store bank in SAMS register
         0SBZ ;           \ disable SAMS card

VARIABLE BLK
: BLOCK  ( n -- addr ) PAGEMEM TUCK MAP ;

: SAM@  ( addr -- )   4K /MOD 1STBANK + BLOCK + @ ;
: SAM!  ( c addr -- ) 4K /MOD 1STBANK + BLOCK + ! ;


: FILL64K     32K 0 DO    I I SAM!   LOOP ;

: ERASE64K    18 10 DO   I BLOCK 4K 0 FILL    LOOP ;
