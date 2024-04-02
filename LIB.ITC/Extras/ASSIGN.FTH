\ assign.fth

NEEDS DUMP FROM DSK1.LOWTOOLS

HEX
CODE :=    ( addr1 addr2 --)  \ 10X FASTER THAN X @ Y !
   W POP,
  *W *TOS MOV,
   TOS POP,
  NEXT,
ENDCODE

HEX
: ASM[   \ Begin Forth Assembly Code within high-level Forth
   HERE 2+ ,            \ compile a pointer to the next cell
   HERE 2+ ,            \ which is the CFA of the inline code
   POSTPONE [           \ switch to interpreter mode
;  IMMEDIATE

: ]ASM   \ Back to high-level Forth
   0209 , HERE 4 + ,    \ LI R9,HERE+4  (move Forth IP to after NEXT,)
   NEXT,                \ NEXT, in ASSEMBLER vocabulary in kernel
    ]                   \ back to FORTH vocabulary and switch ON compiler
; IMMEDIATE 

DECIMAL
VARIABLE X
VARIABLE Y

: TEST1  32000 0 DO  X @ Y !  LOOP ; \ 7.6
: TEST2  32000 0 DO  X Y :=   LOOP ; \ 6.7
: TEST3  32000 0 DO  ASM[  X @@ Y @@ MOV, ]ASM  LOOP ; \ 3.3
