\ gforth's siev.fs (uses address arithmetic and DO for the inner loop)

NEEDS .S    FROM DSK1.TOOLS
NEEDS FILLW FROM DSK1.FILLW \ 16 bit fill
NEEDS C@L   FROM DSK1.SAMS

\ Running on Camel99 Forth
\ Byte Magazine version:  120 seconds
\ GForth version       :   74.1 seconds (38% faster)

 DECIMAL
 8190 CONSTANT SIZE
 0 CONSTANT FLAGS     \ starts a address 0000 in SAMS 64K segment
 FLAGS SIZE + CONSTANT EFLAG

HEX
 1000 CONSTANT 4K

: SAMS.FILLW ( addr len byte) \ erases 4k pages at a time
    -ROT
    BOUNDS ( -- byte lastaddr 1staddr )
    DO
       I VIRT>REAL 4K 2 PICK FILLW
    4K +LOOP
    DROP
;

1 SEGMENT    \ select the 2nd 64K chunk of SAMS card

: DO-PRIME  ( -- n )
  FLAGS SIZE TRUE SAMS.FILLW

  0 3   ( -- accumulator 1st-offset)
  EFLAG FLAGS  \ end-address, start-address
  DO    I C@L    \ I is the array address
        IF  DUP I + DUP EFLAG <
           IF
                EFLAG SWAP
                DO
                    0 I C!L
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
