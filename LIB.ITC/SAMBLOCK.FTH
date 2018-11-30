\ emulating Forth BLOCK in SAMS memory card (4K blocks)

HEX
1000 CONSTANT 4K
  10 CONSTANT 1STBANK    \ don't use the lower 64K

4K MALLOC CONSTANT PAGEMEM

\ adapted from TurboForth for TOS in register
 CODE MAP ( bank addr -- )
         0244 , F000 ,   \ TOS F000 ANDI, \ set to 4k boundary
         09B4 ,          \ TOS   0B SRL,  \ divide by 2048
         0224 , 4000 ,   \ TOS 4000 AI,   \ convert to SAMS register address
         C0B6 ,          \ *SP+  R2 MOV,  \ get bank
         0242 , 00FF ,   \ R2    FF ANDI, \ mask off any crap
         C002 ,          \ R2    R0 MOV,  \ keep a copy
         0A82 ,          \ R0    R2 XOR,  \ Hi/lo bytes are identical
         2880 ,          \ R2    08 SLA,  \ move to high byte
         020C , 1E00 ,   \ R12 1E00 LI,   \ cru address of SAMS
         1D00 ,          \       0 SBO,   \ enable SAMS card
         C502 ,          \ R2  *TOS MOV,  \ poke sams register
         1E00 ,          \        0 SBZ,  \ disable sams card
         C136 ,          \      TOS POP,
         NEXT,
         ENDCODE         \ 34 bytes

: BLOCK  ( n -- addr ) PAGEMEM TUCK MAP ;

: SAMC@  ( addr -- )   4K /MOD 1STBANK + BLOCK + C@ ;
: SAMC!  ( c addr -- ) 4K /MOD 1STBANK + BLOCK + C! ;