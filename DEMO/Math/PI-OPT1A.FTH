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
\ Sept 2025: Using 32bit timer for long duration measurements

\ Sept 6 2025: Improved time by 16% using only Forth changes. Fox

\              Improved xx% by using ERASEW lib file
NEEDS ERASEW FROM DSK1.ERASEW

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS VALUE  FROM DSK1.VALUES
NEEDS D=     FROM DSK1.DOUBLE
NEEDS .R     FROM DSK1.UDOTR
NEEDS ELAPSE FROM DSK1.ELAPSE32

\ this macro improves speed by 2.6%
: M+  S" DUP 0< D+" EVALUATE ; IMMEDIATE
\ for clarity
: S>UD ( u -- ud ) POSTPONE 0 ; IMMEDIATE

\ TI-99 screen timout address
HEX 83D6 CONSTANT TIMEOUT

DECIMAL

0 VALUE POWER  ( adr)
0 VALUE TERM   ( adr)
0 VALUE RESULT ( adr)
0 VALUE SIZE   ( n)

VARIABLE CARRY
\ CHANGED ADD and SUBTRACT to step by 2 through arrays. B FOX
\ 3% speed up on 100 digits, 9% on 500 digits
: ADD ( -- )
  CARRY OFF
  RESULT
  0  SIZE CELLS 2-
  DO
     DUP I + DUP @ S>UD
    TERM I + @ 0  D+  CARRY @ M+
    ( hi) CARRY !
    ( lo) SWAP ( res) !
  -2 +LOOP
  DROP
;

: SUBTRACT ( -- )
  CARRY OFF
  RESULT
  0  SIZE CELLS 2-
  DO
    DUP  I + ( RES) DUP @ S>UD
    TERM I + @ 0  D-  CARRY @ M+
    ( HI) CARRY !
    ( LO) SWAP ( RES) !
  -2 +LOOP
  DROP ;

0 VALUE FACTOR

\ scan forward for cell containing non-zero
\ : +INDEX ( adr -- adr index )
\    -1
\    BEGIN 1+ DUP SIZE -
\    WHILE
\       2DUP CELLS + @
\    UNTIL
\    THEN ;

\ MUCH faster in Camel99 Forth
: +INDEX
    DUP
    SIZE CELLS
    BOUNDS
    DO
       I @ IF I LEAVE THEN
    2 +LOOP
    OVER - 2/
;

\ Using cell sized looping made this part slower.
: DIVIDE ( ADR FACTOR -- )
    TO FACTOR
    CARRY OFF
    +INDEX ( adr index ) SIZE SWAP
    DO
        DUP I CELLS + ( res)
        DUP @  CARRY @  FACTOR  UM/MOD
      ( quot) ROT
      ( res) !
      ( rem) CARRY !
    LOOP
    DROP ;

\ scan backward for cell containing non-zero
: -INDEX ( adr -- adr index )
    SIZE CELLS
    BEGIN 2- DUP
    WHILE
       2DUP + @
    UNTIL
    THEN ;

: MULTIPLY ( adr factor -- )
  TO FACTOR   CARRY OFF
  -INDEX ( adr index ) 0 SWAP
  DO
    DUP I + ( res)
    DUP @  FACTOR  UM*  CARRY @ M+
    ( hi) CARRY !
    ( lo) SWAP ( res) !
  -2 +LOOP
  DROP ;

\ : COPY ( -- ) POWER TERM SIZE  MOVE ;

\ : ZERO? ( result -- f )  +INDEX NIP SIZE = ;
: ZERO? ( result -- F ) SIZE CELLS 0 SKIP NIP 0= ;

0 VALUE PASS
VARIABLE EXP
VARIABLE SIGN

: DIVISOR ( -- N )
  PASS 1 = IF  5  ELSE  239  THEN ;

\ : ERASE  0 FILL ;

: INITIALIZE ( -- )
  POWER SIZE CELLS ERASEW
  TERM  SIZE CELLS ERASEW
  PASS 1 =
  IF
     RESULT SIZE CELLS ERASEW
  THEN
  16  PASS DUP * / POWER !
  POWER  DIVISOR  DIVIDE
  1 EXP !
  PASS 1- SIGN ! ;


DECIMAL
CREATE SCHARS   CHAR | C, CHAR / C, CHAR - C, CHAR \ C,
VARIABLE SPIN#
: SPINCHAR ( -- char ) SPIN# @ 1+ 3 AND DUP SPIN# ! SCHARS + C@ ;
: SPINNER    SPINCHAR VPUT ;

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
      TIMEOUT OFF ( prevent screen from going blank)

      SPINNER
      POWER TERM SIZE MOVE
      TERM  EXP @ DIVIDE
      SIGN @  DUP IF  SUBTRACT  ELSE  ADD  THEN
      0= SIGN !  2 EXP +!
      POWER  DIVISOR DUP *  DIVIDE
      POWER ZERO?
    UNTIL
  LOOP ;

DECIMAL
: PRINT ( -- )
  CR
  RESULT  DUP @ 0 .R  [CHAR] . EMIT CR
  NDIGIT 0
  ?DO
    0 OVER !
    DUP 10000 MULTIPLY
    DUP @  0 <#  # # # #  #> TYPE SPACE
    ?TERMINAL ABORT" Print halted"
  4 +LOOP
  DROP CR ;

: GetNumber ( -- n )
  CR ." How many digits do you want? "
  PAD DUP 20 ACCEPT NUMBER? ABORT" Invalid" CR ;

: .SIZE   CR ." Array size = " SIZE . ." bytes" ;
: .POWER  CR ." POWER array is at  >" POWER U. ;
: .TERM   CR ." TERM  array is at  >" TERM  U. ;
: .RESULT CR ." RESULT array is at >" RESULT U. ;
: .HERE   CR ." HERE is at " HERE U. ;

: PI ( n -- )
  DECIMAL
  PAGE GetNumber DUP TO NDIGIT
  \ array size = ceil(ndigit / log10(2^16))
  109 UM* 525 UM/MOD SWAP ( rem) IF  1+  THEN
  ( extra for accurate last digits)
  2+  TO SIZE

  \ create arrays in un-allocated memory
  .SIZE
  BASE @ HEX
  HERE TO POWER   SIZE 20 + CELLS ALLOT
  .POWER
  HERE TO TERM    SIZE 20 + CELLS ALLOT
  .TERM
  HERE TO RESULT  SIZE 20 + CELLS ALLOT
  .RESULT
  50 ALLOT  ( hold buffer space)
  BASE !

  TIMER-RESET
  CR CalcPi
  CR ." Done!" SPACE  .ELAPSED
  CR ." Press a key to see result" KEY DROP
  PRINT
;

: TITLEPAGE
PAGE ."  Compute PI in ANS Forth Opt7"
CR
CR ." DxForth Revised 2015-02-09  ES"
CR ." Revised for Camel99 2025-09-5 BFox"
CR
CR ." Compute Pi to an arbitrary precision."
CR
CR ." Uses Machin's formula:"
CR ." pi/4 = 4 arctan(1/5) - arctan(1/239)"
CR
CR
CR ." Type  PI  to  run the program" ;
