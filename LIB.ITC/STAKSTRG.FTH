\ STAKSTRG.FTH functions for manipulating Forth Stack strings

NEEDS .S  FROM DSK1.TOOLS

\ stack strings are ridiculously fast because they don't copy strings
\ to new memory. They simply change addresses and length values on the stack.

: 1STCHAR    ( addr len -- c) DROP C@ ;
: LASTCHAR   ( addr len -- c) + 1- C@ ;
: LEN        ( addr len -- addr len len) DUP ; \ for code readability

\ fast version in DSK1.TRAILING
: -TRAILING  ( adr len -- adr len')     \ remove trailing blanks (spaces)
             BEGIN  2DUP LASTCHAR BL =  \ test char at end of string (adr+len)
             WHILE  1-                  \ while it is a blank, decrement length
             REPEAT 0 MAX ;

: CLEAN   ( addr len -- )  BL SKIP  -TRAILING ;  \ remove blanks front and back

: -ALPHA  ( adr len -- n)   \ scan string backwards to find next blank
            BEGIN  2DUP LASTCHAR BL <>
            WHILE  1-
            REPEAT ;

\ Character functions
: BETWEEN ( n lo hi -- ?) 1+ WITHIN ;
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

HEX
: TOUPPER ( c -- c ) DUP LOWER? IF  05F AND THEN ;
: TOLOWER ( c -- c ) DUP UPPER? IF  020 OR  THEN ;

: CHARMAP   ( adr len -- )
         BL WORD FIND ?FIND
        -ROT
         BOUNDS
         DO
            I C@            \ read char
            OVER EXECUTE    \ do the HOF
            I C!            \ store the char
         LOOP
         DROP ;

: BL$      ( -- addr len)  S"  "  ;

: CHAR$    ( <TEXT> -- addr 1) [CHAR] PAD C! PAD 1 ;

\ : C+!      ( n addr -- )   DUP >R  C@ +  R> C! ; \ move to kernel in ASM
: +PLACE   ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

: /LEFT    ( addr len newlen -- addr len)  NIP  ;
: /RIGHT   ( addr len newlen -- addr len)  /STRING 0 MAX ;
: /SEG/    ( addr len start size -- addr len)  >R /RIGHT DROP R> ;
