\ BYTE MAGAZINE SIEVE
\ 10 ITERATION TIMINGS
\                Normal  w/FILLW   OPT      JIT
\ Camel99 DTC     104              67.3
\ TurboForth      107
\ Camel99 ITC     120    117       75.6     49
\ FbForth 2.0:13  174

NEEDS JIT:   FROM DSK1.JITIII
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS FILLW  FROM DSK1.FILLW
NEEDS VTYPE  FROM DSK1.VTYPE

HEX
0101 CONSTANT $0101
2000 CONSTANT FLAGS   0 FLAGS !
\ CREATE FLAGS  2000 ALLOT  0 FLAGS !

DECIMAL
8190 CONSTANT SIZE

HERE
JIT: DO-PRIME
   FLAGS SIZE  $0101 FILLW  ( set array )
   0        ( counter )
   SIZE 0
   DO I FLAGS + C@
      IF
         I 2*  3 +  DUP I +
        BEGIN
          DUP SIZE <
        WHILE
           0 OVER FLAGS +  C!
           OVER +
        REPEAT
        2DROP
        1+
     THEN
   LOOP
;JIT

HERE SWAP - DECIMAL .

: PRIMES ( -- )
   PAGE
   S"  10 Iterations" VTYPE
   10 0 DO  DO-PRIME  CR SPACE . S" Primes" VTYPE  LOOP
   CR S" Done!" VTYPE
;

\ ELAPSE PRIMES
