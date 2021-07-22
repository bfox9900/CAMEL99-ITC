\ PI.FTH  from DxForth with thanks to Ed from Oz.    Jul 2021
\ This program un-covered a bug in V2.67. Fixed in V2.68

\ Revised 2015-02-09  es
\ Revised for Camel99  2021-07-21

\ Compute Pi to an arbitrary precision. Uses Machin's
\ formula:  pi/4 = 4 arctan(1/5) - arctan(1/239)
\

\ Compile with CAMEL99 Forth:
\ INCLUDE DSK*.PI  ( where * is your drive no.)
\
\ This 16-bit implementation allows up to 45,808 digits
\ to be computed before arithmetic overflow occurs.
\
\ The code can be used on 32-bit targets with appropriate
\ changes:
\
\   16-bit             32-bit
\
\   10000 Multiply     100000000 Multiply
\   <# # # # # #>      <# # # # # # # # # #>
\   4 +loop            8 +loop
\   525 um/mod         1050 um/mod
\                      remove 'digits > 45808' warning
\
\ Acknowledgements:
\
\   Roy Williams, Feb 1994
\   J. W. Stumpel, May 1991
\   E. Ford, Aug 2009
\   R. Bishop, Aug 1978
\
\ This code is PUBLIC DOMAIN. Use at your own risk.

\ Modified for Camel99 Forth  Mar 2021 Fox
\ NEEDS DUMP  FROM DSK1.TOOLS  for debugging 
NEEDS D.	  FROM DSK1.DOUBLE
NEEDS VALUE FROM DSK1.VALUES
NEEDS .R    FROM DSK1.UDOTR
NEEDS ELAPSE FROM DSK1.ELAPSE

DECIMAL
0 VALUE POWER  ( adr)
0 VALUE TERM   ( adr)
0 VALUE RESULT ( adr)
0 VALUE SIZE   ( n)

VARIABLE CARRY

: ADD ( -- )
  0 CARRY !
  RESULT
  0 SIZE 1- DO
    I CELLS OVER + ( res) DUP @ 0
    I CELLS TERM + @ 0  D+  CARRY @ M+
    ( hi) CARRY !  ( lo) SWAP ( res) !
  -1 +LOOP  DROP ;

: SUBTRACT ( -- )
  0 CARRY !
  RESULT
  0 SIZE 1- DO
    I CELLS OVER + ( RES) DUP @ 0
    I CELLS TERM + @ 0  D-  CARRY @ M+
    ( HI) CARRY !  ( LO) SWAP ( RES) !
  -1 +LOOP  DROP ;

0 VALUE FACTOR

\ scan forward for cell containing non-zero
: +INDEX ( ADR -- ADR INDEX )
    -1
    BEGIN 1+ DUP SIZE -
    WHILE
       2DUP CELLS + @
    UNTIL
    THEN ;

: (DIVIDE)
  ?DO
     I CELLS OVER + ( res)
     DUP @  CARRY @  FACTOR  UM/MOD
    ( quot) ROT ( res) !  ( rem) CARRY !
  LOOP ;

: DIVIDE ( ADR FACTOR -- )
  TO FACTOR   0 CARRY !  +INDEX
  ( adr index )  SIZE SWAP
  (DIVIDE)
  DROP ;

\ scan backward for cell containing non-zero
: -INDEX ( adr -- adr index )
    SIZE
    BEGIN 1- DUP
    WHILE
       2DUP CELLS + @
    UNTIL
    THEN ;

: MULTIPLY ( adr factor -- )
  TO FACTOR   0 CARRY !  -INDEX
  ( adr index )  0 SWAP
  DO
    I CELLS OVER + ( res)
    DUP @  FACTOR  UM*  CARRY @ M+
    ( hi) CARRY !  ( lo) SWAP ( res) !
  -1 +LOOP
  DROP ;

: COPY ( -- ) POWER TERM SIZE CELLS CMOVE ; \ changed CMOVE to MOVE

: ZERO? ( result -- f )  +INDEX NIP SIZE = ;

0 VALUE PASS
VARIABLE EXP
VARIABLE SIGN

: DIVISOR ( -- N )
  PASS 1 = IF  5  ELSE  239  THEN ;

: ERASE  0 FILL ;

: INITIALIZE ( -- )
  POWER SIZE CELLS ERASE
  TERM  SIZE CELLS ERASE
  PASS 1 = IF  RESULT SIZE CELLS ERASE  THEN
  16  PASS DUP * / POWER !
  POWER  DIVISOR  DIVIDE
  1 EXP !  PASS 1- SIGN ! ;

0 VALUE NDIGIT

: CalcPi ( -- )
  NDIGIT 45800 U> IF
    ." Warning: digits > 45808 will be in error " CR
  THEN

  2 1+ 1
  DO
    I TO PASS
    INITIALIZE
    BEGIN
      COPY
      TERM  EXP @ DIVIDE
      SIGN @  DUP IF  SUBTRACT  ELSE  ADD  THEN
      0= SIGN !  2 EXP +!
      POWER  DIVISOR DUP *  DIVIDE
      POWER ZERO?
    UNTIL
  LOOP ;

\ Camel99 has OUT but I don't use in the Video driver
\ : CR  CR  OUT OFF ;
\ : #   #   OUT 1+! ;

DECIMAL
: (PRINT)
   ?DO
    0 OVER !
    DUP 10000 MULTIPLY
    DUP @  0 <# # # # # #> TYPE SPACE
    VCOL @ 3 + C/L @ > IF CR THEN
  4  +LOOP ;

: PRINT ( -- )
  CR
  RESULT  DUP @ 0 .R  [CHAR] . EMIT SPACE
  NDIGIT 0 (PRINT)
  DROP  CR ;

: PI ( n -- )
( GetNumber ) DUP TO NDIGIT

  \ array size = ceil(ndigit / log10(2^16))
  109 UM* 525 UM/MOD SWAP ( rem) IF  1+  THEN
  2+  TO SIZE    ( extra for accurate last digits)

  50 ALLOT  ( expand the HOLD buffer space)

  HERE TO POWER   SIZE CELLS ALLOT
  HERE TO TERM    SIZE CELLS ALLOT
  HERE TO RESULT  SIZE CELLS ALLOT

  TICKER OFF
  CalcPi
  .ELAPSED
  PRINT
;
DECIMAL
CR
CR .( Usage:  100 PI )
CR .( *This takes ~7.6 secs)
