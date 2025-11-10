\ BYTE MAGAZINE SIEVE with optimization examples
\ 10 ITERATION TIMINGS
\                          Seconds
\ Original code             120
\ ]FLAGS 2* 2DROP           108

NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS AI,    FROM DSK1.LOWTOOLS

DECIMAL
 8190 CONSTANT SIZE
0 VARIABLE FLAGS   SIZE ALLOT  0 FLAGS !

\ Forth arrays are simple addition
CODE ]FLAGS ( n -- addr)   TOS FLAGS AI,   NEXT, ENDCODE

: DO-PRIME
   FLAGS SIZE  1 FILL  ( set array )
   0        ( counter )
   SIZE 0
   DO I ]FLAGS C@
     IF I 2*  3 +  DUP I +
        BEGIN
          DUP SIZE <
        WHILE
          0 OVER ]FLAGS C!
          OVER +
        REPEAT
        2DROP
        1+
     THEN
   LOOP
;

: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;
