\ BYTE MAGAZINE SIEVE
\ 10 ITERATION TIMINGS
\                Normal  FILLW   OPT
\ Camel99 DTC     104     103    67.3
\ TurboForth      107
\ Camel99 ITC     120     117    75.6
\ FbForth 3.0     174

NEEDS ELAPSE FROM DSK1.ELAPSE

DECIMAL
 8190 CONSTANT SIZE
0 VARIABLE FLAGS   SIZE ALLOT  0 FLAGS !

: DO-PRIME
   FLAGS SIZE  1 FILL  ( set array )
   0        ( counter )
   SIZE 0
   DO FLAGS I + C@
     IF I DUP +  3 +  DUP I +
        BEGIN
          DUP SIZE <
        WHILE
          0 OVER FLAGS +  C!
          OVER +
        REPEAT
        DROP DROP
        1+
     THEN
   LOOP
;

: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;
 
INCLUDE DSK1.FILLW 
\ WITH fast fill
HEX 0101 CONSTANT $0101
DECIMAL 
: DO-PRIME3
   FLAGS SIZE  $0101 FILLW  ( set array )
   0        ( counter )
   SIZE 0
   DO FLAGS I + C@
     IF I DUP +  3 +  DUP I +
        BEGIN
          DUP SIZE <
        WHILE
           0 OVER FLAGS +  C!
           OVER +
        REPEAT
        DROP DROP
        1+
     THEN
   LOOP
;

: PRIMES3 ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME3  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;

NEEDS INLINE[  FROM DSK1.INLINE

\ optimized Version
DECIMAL
: DO-PRIME2
  INLINE[ FLAGS SIZE  01 FILL 0   SIZE 0 ]
   DO
     INLINE[ FLAGS I + C@ ]
     IF INLINE[ I 2* 3 +  DUP I + ]
        BEGIN INLINE[ DUP SIZE < ]
        WHILE INLINE[ 0  OVER FLAGS +  C!  OVER + ]
        REPEAT
        INLINE[ 2DROP 1+ ]
     THEN
   LOOP
   CR SPACE . ." Primes"  ;

\ Camel99
: PRIMES-OPT ( -- )
   PAGE ." 10 Iterations"
   10 0 DO  DO-PRIME2 LOOP
   CR
   CR ." Done!"
;
