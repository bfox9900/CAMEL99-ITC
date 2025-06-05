\ PI.FTH from DxForth.
\ Thanks to Ed from Australia for finding the bug in my D+
\
\ Revised 2015-02-09  es
\
\ Compute Pi to an arbitrary precision. Uses Machin's
\ formula:  pi/4 = 4 arctan(1/5) - arctan(1/239)
\
\ Compile with 16-bit DX-Forth: FORTH - INCLUDE PI.F BYE
\ Compile with CAMEL99 Forth: INCLUDE DSK*.PI  ( where * is your drive no.)
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
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS VALUE  FROM DSK1.VALUES
NEEDS D=     FROM DSK1.DOUBLE
NEEDS .R     FROM DSK1.UDOTR
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS MALLOC FROM DSK1.MALLOC

DECIMAL

0 VALUE POWER  ( adr)
0 VALUE TERM   ( adr)
0 VALUE RESULT ( adr)
0 VALUE SIZE   ( n)

VARIABLE CARRY

: ADD ( -- )
  CARRY OFF
  RESULT   0 SIZE 1- DO
    I CELLS OVER + ( res) DUP @ 0
    I CELLS TERM + @ 0  D+  CARRY @ M+
    ( hi) CARRY !  ( lo) SWAP ( res) !
  -1 +LOOP  DROP ;

: SUBTRACT ( -- )
  CARRY OFF
  RESULT   0 SIZE 1- DO
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

: DIVIDE ( ADR FACTOR -- )
  TO FACTOR
  CARRY OFF
  +INDEX ( adr index ) SIZE SWAP
  ?DO
     I CELLS OVER + ( res)
     DUP @  CARRY @  FACTOR  UM/MOD
    ( quot) ROT ( res) !  ( rem) CARRY !
  LOOP
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
  TO FACTOR   CARRY OFF
  -INDEX ( adr index ) 0 SWAP
  DO
    I CELLS OVER + ( res)
    DUP @  FACTOR  UM*  CARRY @ M+
    ( hi) CARRY !  ( lo) SWAP ( res) !
  -1 +LOOP
  DROP ;

: COPY ( -- ) POWER TERM SIZE  MOVE ;

\ : ZERO? ( result -- f )  +INDEX NIP SIZE = ;
: ZERO? ( result -- F ) SIZE CELLS 0 SKIP NIP 0= ;

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

\ VARIABLE OUT
\ : CR  CR  0 OUT ! ;
\ : #   #   1 OUT +! ;

DECIMAL
: PRINT ( -- )
  CR
  RESULT  DUP @ 0 .R  [CHAR] . EMIT CR
  NDIGIT 0
  ?DO
    0 OVER !
    DUP 10000 MULTIPLY
    DUP @  0 <#  # # # #  #> TYPE SPACE
\    OUT @ C/L @ > IF CR THEN  \ not needed for Camel99
    4  +LOOP
  DROP  CR ;

: GetNumber ( -- n )
  CR ." How many digits do you want? "
  PAD DUP 20 ACCEPT NUMBER? ABORT" Invalid" CR ;

: PI ( n -- )
  TICKER OFF
  DUP TO NDIGIT
  \ array size = ceil(ndigit / log10(2^16))
  109 UM* 525 UM/MOD SWAP ( rem) IF  1+  THEN
  ( extra for accurate last digits)
  2+  TO SIZE

  \ create arrays in un-allocated memory
  HERE TO POWER   SIZE 20 + CELLS ALLOT
  HERE TO TERM    SIZE 20 + CELLS ALLOT
  HERE TO RESULT  SIZE 20 + CELLS ALLOT
  50 ALLOT  ( hold buffer space)
  CalcPi
  .ELAPSED
  PRINT
;
\ end
