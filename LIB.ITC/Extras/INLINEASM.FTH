\ inlineasm.fth         BFOX
\ allows inline asm or machine code in colon definition
\ Has an 8 byte overhead versus 10 to 16 for a CODE word
\ : TRIVIAL ( n n -- n) ASM[ *SP+ TOS ADD, ]ASM  42 * ;

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

\ TEST
HEX
\ machine Forth compilers
: DROP,   C136 ,  ;
: DUP,    0646 , C584 , ; ( TOS PUSH, )

: ASMTEST ( -- 1 2 ) 1 2 3  ASM[  DROP, ]ASM  ;

: @,  ( addr -- n) DUP,  C120 ,  ,   ; \  addr @@ TOS MOV,

VARIABLE X   99 X !
: @TEST  ASM[  X @, ]ASM  ;