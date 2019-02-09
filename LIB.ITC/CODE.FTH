\ CODE.FTH let's you make machine code words for use with the assembler

: CODE      ( -- )  HEADER  HERE 2+ , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;

\ machine code demonstration
\ HEX
\ CODE !  ( n addr -- )
\      C536 ,   \ *SP+ *TOS MOV,
\      C136 ,   \ TOS POP,
\      NEXT,
\ ENDCODE
