\ Inline ASM code B. Fox and fixed by Lee Stewart  May 2020

HEX
: ASM[   \ Begin Forth Assembly Code within high-level Forth
   HERE CELL+ ,         \ compile a pointer to the next cell
   HERE CELL+ ,         \ which is the CFA of the inline code
   POSTPONE [           \ switch to interpreter mode
\   ASSEMBLER           \ switch to ASSEMBLER vocabulary if needed
;  IMMEDIATE

: ]ASM   \ Back to high-level Forth
   0209 , HERE 2 CELLS + ,    \ LI R9,HERE+4  (move Forth IP to after NEXT,)
   NEXT,                      \ NEXT, in ASSEMBLER vocabulary in kernel
    ]                         \ back to FORTH vocabulary and switch ON compiler
;  IMMEDIATE
DECIMAL

: TEST    ASM[ TOS INCT, ]ASM ;
