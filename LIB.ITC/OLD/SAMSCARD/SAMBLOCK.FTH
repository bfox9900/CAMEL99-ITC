\ emulating Forth BLOCK in SAMS memory card (4K blocks)

INCLUDE DSK1.TOOLS   \ for debugging only

HEX
1000 CONSTANT 4K
  10 CONSTANT 1STBANK    \ don't use the lower 64K

3000 CONSTANT PAGEMEM    \ paged memory starts here

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

VARIABLE BANK#

HEX
: >BANK  ( 64Kaddr -- addr')
         0 4K UM/MOD   ( -- addr bank#)
         1STBANK +
         DUP BANK# @ =              \ are we using the same bank#
         IF   \ Yes!. Drop the bank# and get out
              DROP
              FFF AND
         ELSE ( offset bank# )      \ MAP in a new bank
              DUP FF00 AND ABORT" SAMS Err!"
              DUP BANK# !           \ update bank#
              SWAP MAP
         THEN PAGEMEM OR           \ return the address in mapped block
;

: PAGED    ( 64Kaddr -- page-addr)
           4K /MOD                 ( -- addr bank#)
           1STBANK +               ( -- addr bank#)
           PAGEMEM TUCK            ( -- addr 3000 bank# 3000)
           MAP                     ( -- addr 3000 )
           + ;                     ( -- addr)

\ uses 1st 64K segment
: C@L  ( addr -- c) PAGED C@ ;
: C!L  ( c addr --) PAGED C! ;
: @L   ( addr -- n) PAGED @ ;
: !L   ( n addr --) PAGED ! ;

