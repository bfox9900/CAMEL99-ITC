\ gforth's siev.fs (uses address arithmetic and DO for the inner loop)

NEEDS .S    FROM DSK1.TOOLS

\ Running on Camel99 Forth
\ Byte Magazine version:  120 seconds
\ GForth version       :   74.1 seconds (38% faster)

\ DECIMAL
\ 8190 CONSTANT SIZE
\ VARIABLE FLAGS   SIZE ALLOT  0 FLAGS !
\ FLAGS SIZE + CONSTANT EFLAG

NEEDS FILLW   FROM  DSK1.FILLW

\ Use 8K in low RAM for the array
HEX 2000 CONSTANT FLAGS    0 FLAGS !
HEX 0101 CONSTANT $0101

DECIMAL
8190 CONSTANT SIZE

FLAGS SIZE + CONSTANT EFLAG

JIT: DO-PRIME  ( -- n )
   FLAGS SIZE  $0101 FILLW  ( set array )

  0 3
  EFLAG FLAGS
  DO   I C@
       IF  DUP I + DUP EFLAG <
           IF
                EFLAG SWAP
                DO
                    0 I C!
                DUP +LOOP
           ELSE
                DROP
           THEN
           SWAP 1+ SWAP
        THEN
        CELL
    LOOP
    DROP
;JIT

: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO  DO-PRIME  CR SPACE . ." Primes"  LOOP
   CR ." Done!"
;

INCLUDE DSK1.ELAPSE

\ run with: ELAPSE PRIMES
