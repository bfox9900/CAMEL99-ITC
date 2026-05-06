\ gforth's siev.fs (uses address arithmetic and DO for the inner loop)

NEEDS .S    FROM DSK1.TOOLS

\ Running on Camel99 Forth (ITC)
\ Byte Magazine version:  120 seconds
\ GForth version       :   74.1 seconds (38% faster)
\ GForth JIT compiled  :   32.2


NEEDS FILLW   FROM DSK1.FILLW  \ 16 bit fill
NEEDS JIT:    FROM DSK1.JIT    \ JIT V1 puts code in LOW RAM

DECIMAL
8190 CONSTANT SIZE
VARIABLE FLAGS   SIZE ALLOT  0 FLAGS !
FLAGS SIZE + CONSTANT EFLAG

JIT: DO-PRIME  ( -- n )
    FLAGS SIZE  TRUE FILLW  ( set array )

    0 3
    EFLAG FLAGS ( -- 'last 'first )
    DO                     \ I is address in FLAGS
        I C@
        IF  DUP I + DUP EFLAG <
            IF
                EFLAG SWAP
                DO
                    0 I C!  \ reset the byte
                DUP +LOOP
            ELSE
                DROP
            THEN
            SWAP 1+ SWAP    \ update counter on data stack
        THEN
        CELL+
    LOOP
    DROP                   \ drop the offset
;JIT

: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;

INCLUDE DSK1.ELAPSE
CR
CR
CR .( Run with: ELAPSE PRIMES)
