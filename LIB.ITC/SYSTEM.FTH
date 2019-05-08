CR .( compiling ANS Forth extensions...)
 
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
: CODE      ( -- )  HEADER  HERE 2+ , !CSP ;
: NEXT,     ( -- )  045A , ;  \ B *R10
: ENDCODE   ( -- )  ?CSP  ;
.( .)
\ CELLS ANS Forth Core wordset
 
\ 1 cell alias. *FOR CODE WORDS ONLY*
: ALIAS ( <newname>  <oldword> ) CODE '  2+   HERE 2- ! ;
ALIAS CELLS  2*
ALIAS CELL+  2+
ALIAS CHAR+  1+
ALIAS >BODY  2+
.( .)
: CHARS ;  \ noop in CAMEL99 Forth
 
\ CHAR   converts ASCII char to a number
\ for interpret mode
: CHAR    ( -- <c>) BL WORD CHAR+ C@ ;
\ for compiling a colon definition
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE
 
\ 6.2.0945 COMPILE,      compile comma
\ for ANS compatibility. Same as comma in CAMEL99
: COMPILE, ( n -- ) S" ," EVALUATE ; IMMEDIATE
 
.( .)
\ : EMIT  ( -- ) 'EMIT @ EXECUTE ;   \ vectored EMIT word
 
 
\ : TTYPAGE   0C EMIT ;               \ simple TTY control char
\ : CR    ( -- ) 'CR @ EXECUTE ;     \ vectored carriage return
 
\ : PAGE  ( -- ) 'PAGE @ EXECUTE ;
\
\ ' TTYPAGE  'PAGE !
 
CR .( Camel99 Forth for TI-99 ready)
CR
 
 
