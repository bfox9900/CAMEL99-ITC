\ gforth's siev.fs (uses address arithmetic and DO for the inner loop)

NEEDS .S    FROM DSK1.TOOLS
NEEDS JIT:  FROM DSK1.JIT
NEEDS ELAPSE FROM DSK1.ELAPSE


\ Running on Camel99 Forth
\ Byte Magazine version:  120 seconds
\ GForth version       :   74.1 seconds (38% faster)


\ Use 8K in low RAM for the array
HEX 2000 CONSTANT FLAGS   0 FLAGS !

DECIMAL
8190 CONSTANT SIZE

FLAGS SIZE + CONSTANT EFLAG


JIT: JIT-PRIME  ( -- n )
  FLAGS SIZE 1 FILL
  0 3   ( -- accumulator 1st-offset)
  EFLAG FLAGS  \ end-address, start-address
  DO   I C@    \ I is the array address
       IF  DUP I + DUP EFLAG <
           IF
                EFLAG SWAP
                DO
                    0 I C!
                DUP +LOOP
           ELSE
                 DROP
           THEN
           SWAP 1+ SWAP  \ inc. the accumulator
        THEN
        CELL+            \ inc. offset by 2
    LOOP
    DROP
;JIT


: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  JIT-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;

CR .( run with: ELAPSE PRIMES)
