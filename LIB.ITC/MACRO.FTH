\ Macro.fth   BY WIL BADEN  r.i.p    

\ Usage:  MACRO RDROP  " R> DROP" 

: SLITERAL ( ca u --) \ Not in Camel99 Forth kernel
  POSTPONE (S")  S,  ; IMMEDIATE

: MACRO  
   : CHAR PARSE  POSTPONE SLITERAL  POSTPONE EVALUATE POSTPONE ;
   IMMEDIATE ;
