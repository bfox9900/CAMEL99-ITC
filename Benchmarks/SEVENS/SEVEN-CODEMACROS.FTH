\ lucien2 Version of FIG Forth code PORTED to CAMEL99 Forth 
\ Uses Machine Forth macros 

\ ** non-scrolling version **

\ NEEDS DUMP   FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS ()@,   FROM DSK1.CODEMACROS

DECIMAL

180 CONSTANT SIZE
\ variable         fast fetchers
VARIABLE i        MACRO i@   i @, ;MACRO
VARIABLE X        MACRO X@   X @, ;MACRO
VARIABLE POWER
VARIABLE LENGTH

CREATE A1   SIZE CELLS ALLOT
CREATE A2   SIZE CELLS ALLOT

CREATE PAD  256 ALLOT

\ Integer Arrays that is indexed addressing
MACRO: ]A1@ ( ndx -- n)   A1 ()@,  ;MACRO
MACRO: ]A2@ ( ndx -- n)   A2 ()@,  ;MACRO

MACRO: ]A1! ( n ndx --)   A1 ()!,  ;MACRO
MACRO: ]A2! ( n ndx --)   A2 ()!,  ;MACRO

\ Note: Used UM/MOD,  un-signed division because it's faster
: A1*7->A2 ( -- )
           i OFF
           X OFF
           BEGIN
               i@ ]A1@ DUP 0=
               i@ LENGTH @ > AND
               X@ 0=   AND
           0= WHILE
               7 * X@ + S>D  10 UM/MOD  X !  i@ ]A2!
               i 1+!
           REPEAT
           DROP
           i@ LENGTH ! ;

\ number converion helpers
: <#      ( -- ) PAD HP ! ;        \ set HP to buffer for number conversion
: #>      ( -- pad length ) PAD HP @ OVER - ;
: HOLD   ( char -- )  HP @ C!  HP 1+! ;  \ hold digit in pad, bump pointer

: A2>$   ( -- addr len)  \ array to text string
       <#
       -1 LENGTH @ 1-
        DO
           I ]A2@ [CHAR] 0 +  HOLD
        -1 +LOOP
        #>                            \ compute length
       [CHAR] 0 SKIP ;                \ skip leading zeros

: SEVENS? ( -- ?)
        0
        LENGTH @ 1- 0
        DO
           1+ I ]A2@ 7 = AND
           DUP 4 > IF LEAVE THEN
        LOOP
;

: INTRO
  PAGE ." The 5 Sevens Problem"
  CR
  CR   ." Press a key to start"  KEY DROP
;

: CALCULATOR
   CR ." Working ..."
   BEGIN
        A1*7->A2
        A2 A1  LENGTH @ CELLS MOVE
        POWER 1+!
        SEVENS?
     UNTIL ;

: ERASE  ( address length --) 0 FILL ;
: EMPTY  ( array --) SIZE CELLS ERASE ;

: SETUP
     A1 EMPTY
     A2 EMPTY
     7 A1 !    2 POWER !   LENGTH OFF
     PAGE
     TICKER OFF
;

: RESULTS
     CR
     CR
     CR
     CR ." The Answer is 7 ^" POWER @ 1- .
     CR .ELAPSED
     CR
;

: RUNFASTER     INTRO   SETUP   CALCULATOR  RESULTS  A2>$ TYPE ;

\ CAMEL99 time  33
