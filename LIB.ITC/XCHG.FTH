\ XCHG.FTH  6x faster than Forth

\ usage:   X Y XCHG  \ moves contents from X->Y & Y->X
HEX
CODE XCHG   ( adr1 adr2 -- ) \ exchange values of 2 variables
C036 , \               R0 POP,
C210 , \       R0 **   W  MOV,    \ save contents1 in W
C414 , \      *TOS  R0 ** MOV,    \ mem2mem: contents of TOS to address in R0
C508 , \       W     *TOS MOV,
C136 , \              TOS POP,
NEXT,
ENDCODE
