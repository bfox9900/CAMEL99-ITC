CR .( compiling ANS Forth extensions...)
\ Smart including. Usage: NEEDS HCHAR FROM DSK1.GRAFIX
: PARSE-NAME ( <text> -- adr len ) BL PARSE-WORD ; \ Forth 2012 word
: NEEDS  ( -- ?)  BL WORD FIND NIP  ;
: FROM   ( ? -- ) PARSE-NAME ROT 0= IF  INCLUDED  ELSE 2DROP  THEN ;
: INCLUDE ( <text>)
  PARSE-NAME INCLUDED SPACE LINES @ DECIMAL . ." lines"  HEX ;
.( .)
HEX
: CODE      ( -- )  HEADER  HERE 2+ , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;

\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( XT -- <newname> ) 2+ HEADER  , ;
' 2* ALIAS CELLS  ' 2+ ALIAS CELL+   ' 1+ ALIAS CHAR+  ' 2+ ALIAS >BODY

: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE

: CHARS ;  \ noop in CAMEL99 Forth
: CHAR    ( -- <c>) PARSE-NAME DROP C@ ;
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE
DECIMAL
