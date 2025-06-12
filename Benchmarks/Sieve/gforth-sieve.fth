\ gforth's siev.fs (uses address arithmetic and DO for the inner loop)

INCLUDE DSK1.TOOLS
INCLUDE DSK1.EMPTY


\ Running on Camel99 Forth
\ Byte Magazine version:  120 seconds
\ GForth version       :   74.1 seconds (38% faster)

DECIMAL
8190 CONSTANT SIZE
VARIABLE FLAGS   SIZE ALLOT  0 FLAGS !

FLAGS SIZE + CONSTANT EFLAG


: DO-PRIME  ( -- n )
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
    DROP ;


: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;

INCLUDE DSK1.ELAPSE

\ run with: ELAPSE PRIMES

INCLUDE DSK1.JIT
: ?INNER
    DUP I + DUP EFLAG > IF DROP  EXIT THEN
    EFLAG SWAP
    DO
        0 I C!
    DUP +LOOP
;

: JIT-PRIME  ( -- n )
  FLAGS SIZE 1 FILL
  0 3   ( -- accumulator 1st-offset)
  EFLAG FLAGS  \ end-address, start-address
  DO   I C@    \ I is the array address
       IF
           ?INNER
           SWAP 1+ SWAP  \ inc. the accumulator
        THEN
        2+            \ inc. offset by 2
    LOOP
    DROP
;

: PRIMES2 ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  JIT-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;
