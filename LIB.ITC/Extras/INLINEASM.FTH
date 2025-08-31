\ inlineasm.fth         BFOX
\ allows inline asm or machine code in colon definition

HEX
: ASM[   \ Begin Forth Assembly Code within high-level Forth
   HERE CELL+ ,            \ compile a pointer to the next cell
   HERE CELL+ ,            \ which is the CFA of the inline code
   POSTPONE [              \ switch to interpreter mode
;  IMMEDIATE

: ]ASM   \ Back to high-level Forth
   0209 , HERE 2 CELLS + ,  \ LI R9,HERE+4  (move Forth IP to after NEXT,)
   NEXT,                    \ NEXT, in ASSEMBLER vocabulary in kernel
   ]                        \ switch ON compiler
; IMMEDIATE
