\ CODE.FTH let's you make machine code words
\ without loading the assembler

: CODE      ( -- )  HEADER  HERE >BODY , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10 (machine code)
: ENDCODE   ( -- )  ?CSP  ; \ check stack position 

\ machine code demonstration
\ HEX
\ CODE !  ( n addr -- ) 
\      C536 ,   \ *SP+ *TOS MOV,
\      C136 ,   \ TOS POP,
\      NEXT,
\ ENDCODE
