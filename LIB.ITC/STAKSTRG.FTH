\ STAKSTRG.FTH functions for manipulating Forth Stack strings

NEEDS .S  FROM DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING

\ stack strings are ridiculously fast because they don't copy strings
\ to new memory. They simply change addresses and length values on the stack.

: LEN      ( addr len -- addr len len) DUP ;
: 1STCHAR  ( addr len -- addr len c) OVER C@ ;
: LASTCHAR ( addr len -- addr len c) 2DUP + 1- C@ ;

: CLEAN   ( addr len -- )  BL SKIP  -TRAILING ;  \ remove blanks front and back

: -ALPHA  ( adr len -- adr n)   \ scan string backwards to find next blank
            BEGIN  LASTCHAR BL <>
            WHILE  1-
            REPEAT ;

\ Character functions
: BETWEEN ( n lo hi -- ?) 1+ WITHIN ;
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

HEX
: TOUPPER ( c -- c ) DUP LOWER? IF  05F AND THEN ;
: TOLOWER ( c -- c ) DUP UPPER? IF  020 OR  THEN ;

\ PAD, builds a counted string in PAD 1 char a time
: PAD,   ( char -- ) PAD DUP C@ 1+ + C!  1 PAD C+! ;

\ MAP$ uses functions that take a char and return a char
VARIABLE MAPPER
: MAP$   ( adr len xt -- adr len ) \ returns a string at PAD
         MAPPER @ >R           \ Makes this re-entrant
         MAPPER !
         PAD OFF               \ reset PAD as counted string
         BOUNDS
         DO
            I C@ MAPPER PERFORM  PAD,  \ process char, compile into PAD
         LOOP
         R> MAPPER !
         PAD COUNT ;           \ return new string

: A$  S" This is a test string." ;
  A$ ' TOUPPER MAP$ TYPE


VARIABLE REDUCER
\ XT must be a function that takes 2 arguments and returns 1 argument.
: REDUCE$ ( adr len xt -- n) \ returns an single number
         REDUCER @ >R       \ makes this re-entrant
         REDUCER !
         0 -ROT             \ accumulator on DATA stack
         BOUNDS
         DO
            I C@            \ read char
            REDUCER PERFORM \ do the HOF, result must go into acculator
         LOOP
         R> REDUCER ! ;

\ REDUCE$ tester
: SUMPRINT ( n n -- n)
           CR OVER . ." + " DUP .  +  DUP ." = "  .  ;

DECIMAL S" 01234" ' SUMPRINT REDUCE$ .           

: BL$      ( -- addr len)  S"  "  ;
: CHAR$    ( <TEXT> -- addr 1) [CHAR] PAD C! PAD 1 ;
: +PLACE   ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;
: /LEFT    ( addr len newlen -- addr len)  NIP  ;
: /RIGHT   ( addr len newlen -- addr len)  0 MAX  /STRING ;
: /SEG/    ( addr len start size -- addr len)  >R /RIGHT DROP R> ;
