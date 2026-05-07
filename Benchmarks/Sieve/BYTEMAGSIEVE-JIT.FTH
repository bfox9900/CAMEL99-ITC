\ BYTE MAGAZINE SIEVE
\ 10 ITERATION TIMINGS
\                Normal  w/FILLW   OPT      JIT
\ Camel99 DTC     104              67.3
\ TurboForth      107
\ Camel99 ITC     120    117       75.6     50
\ FbForth 2.0:13  174

NEEDS JIT:   FROM DSK1.JIT
NEEDS ELAPSE FROM DSK1.ELAPSE
\ NEEDS FILLW  FROM DSK1.FILLW
\ NEEDS VTYPE  FROM DSK1.VTYPE

DECIMAL
8190 CONSTANT SIZE
VARIABLE FLAGS  SIZE ALLOT   0 FLAGS !

HERE
JIT: DO-PRIME
   FLAGS SIZE  1 FILL  ( set array )
   0        ( counter )
   SIZE 0
   DO I FLAGS + C@
      IF
         I I +  3 +  DUP I +
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
;JIT

HERE SWAP - DECIMAL .

: PRIMES ( -- )
   PAGE
   S"  10 Iterations" TYPE
   10 0 DO  DO-PRIME  CR SPACE . S" Primes" TYPE  LOOP
   CR S" Done!" TYPE
;

\ ELAPSE PRIMES
