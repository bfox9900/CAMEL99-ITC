\ Leo Wong  21 June 02004 02003 fyj. 

: SLITERAL ( ca u --) \ Not in Camel99 Forth kernel
  POSTPONE (S")  S,  ; IMMEDIATE

: MACRO  
   : CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE POSTPONE ;
   IMMEDIATE ;
   
\ Interesting but 5x SLOWER than using DO LOOP or Camel99 FORNEXT 
MACRO FOR " ( +U -- )  BEGIN ?DUP WHILE 1- >R"
MACRO NEXT " ( -- )    R> REPEAT"
MACRO FEXIT  " ( -- )  R> DROP EXIT"
MACRO FLEAVE " ( -- )  R> DROP 0 >R"

