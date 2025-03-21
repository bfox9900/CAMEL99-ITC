CR .( CODESEG.FTH  swappable code segment in upper RAM  May 2020  B Fox )
\ Concept: Use 8K segement from E000 to EFFF as a mapped space for Forth code
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS FORGET FROM DSK1.FORGET

HEX E000 CONSTANT CSEG \ window for SAMS code 

\ reserve addresses at the bottom of the SAMS page
\ These hold the dictionary linkage to attach SAMS to Forth 
VARIABLE OLDDP      \ remember the dictionary pointer
VARIABLE OLDH       \ remember the HEAP (low RAM)
VARIABLE OLDLINK    \ link field of a dummy word after PERMANENT


: TRANSIENT ( -- )
       H @ DUP>R  OLDH !
       HERE OLDDP !    \ save the dictionary pointer.
       R> DP !         \ Point DP to transient memory
;

: PERMANENT ( -- )
       HERE H !                    \ update heap pointer (LOW RAM)
       S"  " HEADER,               \ DUMMY word is blank. Can't be found
       LATEST @ NFA>LFA OLDLINK !  \ Remember LFA of DUMMY
       OLDDP @ DP !                \ restore normal dictionary
       OLDDP OFF
;

HEX
\ translated from TurboForth
 CODE MAP ( bank addr -- )
         0244 , F000 ,   \ TOS F000 ANDI, \ set to 4k boundary
         09B4 ,          \ TOS   0B SRL,  \ divide by 2048
         0224 , 4000 ,   \ TOS 4000 AI,   \ convert to SAMS register address
         C0B6 ,          \ *SP+  R2 MOV,  \ get bank
         0242 , 00FF ,   \ R2    FF ANDI, \ mask off any crap
         C002 ,          \ R2    R0 MOV,  \ keep a copy
         0A82 ,          \ R0    R2 XOR,  \ combine r0&r2. Hi&lo bytes are same
         2880 ,          \ R2    08 SLA,  \ move to high byte
         020C , 1E00 ,   \ R12 1E00 LI,   \ cru address of SAMS
         1D00 ,          \       0 SBO,   \ enable SAMS card
         C502 ,          \ R2  *TOS MOV,  \ poke sams register
         1E00 ,          \        0 SBZ,  \ disable sams card
         C136 ,          \      TOS POP,
         NEXT,
         ENDCODE

VARIABLE SAMSPAGE 
: CODEPAGE ( page# --) DUP SAMSPAGE ! CSEG MAP ;
: ?MAPPED  ( page# --) SAMSPAGE @ OVER <> IF CODEPAGE THEN ;

10 CODEPAGE
CSEG TRANSIENT

: STAR    10 ?MAPPED  [CHAR] * EMIT ;
: STARS   10 ?MAPPED  0 ?DO STAR LOOP ;

 PERMANENT

 : *FORTH* ;
