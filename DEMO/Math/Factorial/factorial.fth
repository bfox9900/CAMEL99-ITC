\ factorial.fth
INCLUDE DSK1.TOOLS
INCLUDE DSK1.UDOTR

include DSK1.DOUBLE

\ Rossetta code
: FAC ( n -- n! ) 1 SWAP 1+  1 ?DO I * LOOP ;

\ 32 bit version  modified

: FACTORIAL ( n -- d) \ returns 32 bit integer
    1 0 ROT 1+ 2
    ?DO
        I 1 M*/
    LOOP
;


: .FAC
   PAGE  ." 16 bit Factorials in Forth"   9 1
   DO
     CR I DUP 3 .R  FAC ." ! = "  U.
   LOOP
;

: .FAC32
   PAGE  ." 32 bit Factorials in Forth"
   13 1
   DO
     CR I DUP 3  .R   FACTORIAL ." ! = "  UD.
   LOOP
;
