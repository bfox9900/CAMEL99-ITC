CR .( compiling extensions for DTC Forth ...)

\ USE:  NEEDS HCHAR FROM DSK1.GRAFIX.F
: NEEDS  ( -- ?)  BL WORD FIND NIP  ;

: FROM   ( ? -- )
         BL PARSE-WORD ROT ( addr len ? --)
         0= IF  INCLUDED
         ELSE   2DROP
         THEN ;
.( .)
\ INCLUDE  Forth 2012 word
: PARSE-NAME ( <text> -- adr len ) BL PARSE-WORD ; \ Forth 2012 word
: INCLUDE  ( <text> -- )  PARSE-NAME INCLUDED SPACE ;

\ CODE.FTH let's you make machine code words
\ for use with the assembler
HEX
: CODE      ( -- )  HEADER  !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;
: >BODY  4 + ;

.( .)
\ CELLS ANS Forth Core wordset
\ 1 cell *DTC* alias. *FOR CODE WORDS ONLY*
\ : ALIAS ( <newname>  <oldword> ) CREATE  '   , DOES> @  ;
: CELLS  2* ;
: CELL+  2+ ;
: CHAR+  1+ ;
: CHARS ;  \ noop in CAMEL99 Forth

.( .)
\ CHAR   converts ASCII char to a number
\ for interpret mode
: CHAR    ( -- <c>) BL WORD CHAR+ C@ ;
\ for compiling a colon definition
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE

\ 6.2.0945 COMPILE,      compile comma
\ for ANS compatibility. Same as comma in CAMEL99
: COMPILE, ( n -- ) S" ," EVALUATE ; IMMEDIATE

CR .( Camel99 Forth for TI-99 ready)
CR
