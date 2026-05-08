\ BYTE MAGAZINE SIEVE with easy optimization examples
\ 10 ITERATION TIMINGS
\                          Seconds
\ Original code             120
\ ]FLAGS 2* 2DROP           108    11% better

NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS AI,    FROM DSK1.LOWTOOLS
NEEDS CARRAY FROM DSK1.ARRAYS

DECIMAL
8190 CONSTANT SIZE
SIZE ARRAY ]FLAGS

0 ]FLAGS CONSTANT []FLAGS
HEX
CODE SETTRUE ( addr cnt -- ) \ set memory cells to TRUE ( -1 )
    C076 ,  \    *SP+ R1 MOV,
            \    BEGIN,
    0731 ,  \        R1 *+ SETO,
    0644 ,  \        TOS DECT,
    15FD ,  \    LTE UNTIL,
    C136 ,  \    TOS POP,
    NEXT,
ENDCODE
DECIMAL

   []FLAGS OFF
: DO-PRIME
   []FLAGS CELL+ SIZE CELLS 2-  SETTRUE  ( set array )
   0        ( counter )
   SIZE 0
   DO I ]FLAGS @
      IF I 2*  3 +  DUP I +
        BEGIN
          DUP SIZE <
        WHILE
          DUP ]FLAGS OFF
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
;  \ 1:37.73  10% faster using ARRAY vs CARRAY
   \ with SETTRUE  1:35.36
