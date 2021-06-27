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

: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE

\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( <newname>  <oldword> ) CODE '  2+   HERE 2- ! ;
  ALIAS CELLS  2*  ALIAS CELL+  2+   ALIAS CHAR+  1+   ALIAS >BODY  2+

: POSTPONE ( <name> -- ) \ replaces COMPILE and [COMPILE]
          ?COMP
          BL WORD FIND DUP 0= ?ERR
          0< IF   COMPILE COMPILE
          THEN  , ; IMMEDIATE

: CHARS ;  \ noop in CAMEL99 Forth
: CHAR    ( -- <c>) BL PARSE-WORD DROP C@ ;
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE
DECIMAL 
