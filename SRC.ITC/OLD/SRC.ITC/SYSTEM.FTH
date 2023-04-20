CR .( Extensions...)

: PARSE-NAME  BL PARSE-WORD ;
: CHAR        PARSE-NAME DROP C@ ;
: [CHAR]      ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE

: NEEDS  ( -- ?)  BL WORD FIND NIP  ;
: FROM   ( ? -- ) PARSE-NAME ROT IF  2DROP EXIT THEN  INCLUDED ;
: INCLUDE ( <text>)
  PARSE-NAME INCLUDED SPACE LINES @ DECIMAL . ." lines" ;
.( .)
HEX
: CODE      ( -- )  HEADER  HERE 2+ , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;

\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( XT -- <newname> ) 2+ HEADER  , ;
' 2* ALIAS CELLS  ' 2+ ALIAS CELL+   ' 1+ ALIAS CHAR+  ' 2+ ALIAS >BODY
: CHARS ;
.( .)
: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE
.( .)

DECIMAL
