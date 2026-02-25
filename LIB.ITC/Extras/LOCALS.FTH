\ locals.fth for Camel99 Forth      Oct 2022 Brian Fox
\ *Do not use with DO LOOPS*

\ non-standard but TINY for TI-99.
\ creates a stack frame on the return stack
\ Uses pre-named local variables
\ Each local returns the address of a cell in the stack frame

\ Feb 2026: LOCALS moves data stack args into stack frame automagically

NEEDS DUMP   FROM DSK1.TOOLS

HERE
HEX
CODE LOCALS ( n --) \ build a stack frame n cells deep, copy data stack
C007 , \  RP R0 MOV,  \ DUP return stack pointer in R0
0A14 , \ TOS 1 SLA,  \ CELLS
61C4 , \  TOS RP SUB, \ allocate n cells on Rstack

C207 , \  RP  W  MOV, \ COPY the new Rstack pointer to W
\  BEGIN,
CE36 , \    *SP+  *W+ MOV,  \ copy data stack to stack frame
0644 , \     TOS DECT,
16FD , \  EQ UNTIL,

0647 , C5C0 , \  R0 RPUSH,   \ push old RP onto top of frame for collapsing later
C136 , \  TOS POP,
  NEXT,
ENDCODE

\ collapse stack frame: get old RP on the Rstack into RP register
CODE /LOCALS  ( -- )
  C1D7 ,  \ *RP RP MOV,
  NEXT,
ENDCODE

: LOCAL:  ( n -- ) \ name some local variables
  DUP 1- 0< ABORT" 1 or more expected"
  CREATE  CELLS ,  \ record the cell offset for this local
  ;CODE
    0646 , C584 , \ TOS PUSH,    \ make room in TOS
    C107 ,        \ RP TOS MOV,  \ get the rstack pointer
    A118 ,        \ *W TOS ADD,  \ add the offset for this local var
    NEXT,
  ENDCODE

DECIMAL
HERE SWAP - SPACE . .( bytes )
