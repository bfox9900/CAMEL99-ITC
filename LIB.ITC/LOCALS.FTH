\ locals.fth for Camel99 Forth                      Oct 2022 Brian Fox
\ non-standard but TINY for TI-99. (74 bytes)
\ *Care is required with DO LOOPS*
\ create a stack frame on the return stack
\ create named local variables that index the stack frame
\ Each local returns the address of a cell in the stack frame

HERE
HEX
CODE LOCALS ( n --) \ build a stack frame n cells deep
\ RP R0 MOV, TOS 1 SLA, TOS RP SUB, R0 RPUSH,     TOS POP,
  C007 ,      0A14 ,     61C4 ,     0647 , C5C0 , C136 ,  NEXT,  ENDCODE

\ collapse stack frame: *RP RP MOV,
CODE /LOCALS  ( -- )   C1D7 , NEXT,

: LOCAL:  ( n -- ) \ name some local variables
  CREATE  2* ,
  ;CODE
\ TOS PUSH,     RP TOS MOV, *W TOS ADD,
    0646 , C584 , C107 ,     A118 ,
    NEXT,
  ENDCODE

DECIMAL
HERE SWAP - SPACE . .( bytes )

\ example:
\ 1 LOCAL: X1   2 LOCAL: X2
\ DECIMAL
\ : ADD ( n n -- n )
\   2 LOCALS
\    X1 ! X2 !
\    X1 @ X2 @ +
\  /LOCALS
\ ;
