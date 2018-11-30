\ STAKSTRG.FTH functions for manipulating Forth Stack strings

\ stack strings are ridiculously fast because they don't copy strings 
\ to new memory. They simply change addresses and length values on the stack.

: 1STCHAR    ( addr len -- c) DROP C@ ; 
: LASTCHAR   ( addr len -- c) + 1- C@ ;
: LEN        ( addr len -- addr len len) DUP ; \ for code readability

: -TRAILING  ( adr len -- adr len')     \ remove trailing blanks (spaces)
             BEGIN  2DUP LASTCHAR BL =  \ test char at end of string (adr+len)
             WHILE  1-                  \ while it is a blank, decrement length
             REPEAT ;
             
: CLEAN   ( addr len -- )  BL SKIP  -TRAILING ;  \ remove blanks front and back

: -ALPHA  ( adr len -- n)   \ scan string backwards to find next blank
            BEGIN  2DUP LASTCHAR BL <>
            WHILE  1-
            REPEAT ;
            
: BL$      ( -- addr len)  S"  "  ;
: C+!      ( n addr -- )   DUP >R  C@ +  R> C! ;
: +PLACE   ( addr n $ -- ) 2DUP 2>R  COUNT +  SWAP CMOVE 2R> C+! ;

: /LEFT    ( addr len newlen -- addr len)  NIP  ;
: /RIGHT   ( addr len newlen -- addr len)  0 MAX  /STRING ;
: /SEG/    ( addr len start size -- addr len)  >R /RIGHT DROP R> ;
