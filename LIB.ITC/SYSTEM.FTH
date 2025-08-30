CR .( ANS FORTH Extensions...)

: PARSE-NAME  BL PARSE-WORD ;
: CHAR        PARSE-NAME DROP C@ ;
: [CHAR]      ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE

: NEEDS  ( -- ?)  BL WORD FIND NIP  ;
: FROM   ( ? -- ) PARSE-NAME ROT IF  2DROP EXIT THEN  INCLUDED ;
: INCLUDE ( <text>)
  PARSE-NAME INCLUDED SPACE LINES @ DECIMAL . ." lines" ;
.( .)
HEX
\ aliases for ANS compliance
CODE CELLS   A104 , NEXT, ENDCODE  \ 2*
CODE CHAR+   0584 , NEXT, ENDCODE  \ 1+
CODE >BODY   05C4 , NEXT, ENDCODE  \ 2+
CODE CELL+   05C4 , NEXT, ENDCODE  \ 2+

\ support for machine code
: CODE      ( -- )  HEADER  HERE CELL+ , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;

: CHARS  ; IMMEDIATE \ noop

.( .)
: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE
.( .)

DECIMAL
