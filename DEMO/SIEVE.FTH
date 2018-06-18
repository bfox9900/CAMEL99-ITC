\ Sieve of Erathosenes in Forth
\ Tested with TurboForth and CAMEL99 Forth

INCLUDE DSK1.ELAPSE.F

\ array calculators as text macros
: []@ ( n addr -- n ) S" + C@" EVALUATE ; IMMEDIATE
: []! ( n addr -- )   S" + C!" EVALUATE ; IMMEDIATE

\ Squared operation text macro for clarity
: ^2  ( n -- n^2)    S" DUP *" EVALUATE ; IMMEDIATE

: ERASE  ( addr n -- ) 0 FILL ;

HEX
: FREEMEM  ( -- n) FF00 HERE - ;
: ?MEM     ( n -- )  FREEMEM OVER < ABORT" Out of memory" ;

\ byte array uses unallocated memory at HERE
DECIMAL
: PRIMES ( n -- )
        ?MEM
        CR ." Running..."
        HERE OVER ERASE
        1 0 HERE []!       \ mark as prime like 'C' version
        1 1 HERE []!
        2                  \ start at 2
        BEGIN
           2DUP ^2 >
        WHILE
           DUP HERE []@ 0=
           IF  2DUP ^2
               DO
                  1 I HERE []!
               DUP +LOOP
           THEN
           1+
        REPEAT
        CR ." Complete."
        .ELAPSED
        CR
        DROP
        CR ." Press any key to see primes:" KEY DROP
        ." Primes: " 2 DO  I HERE []@ 0= IF I . THEN  LOOP
;


\ 1000 primes
\ X BASIC         14.3 secs
\ TI BASIC        11.9

\ 10000 primes
\ TF               8.0
\ CAMEL99 ITC     10.28
\ CAMEL99 V2 ITC   8.25    ( optimized HERE )
\ CAMEL99 V2 with []!, []@ as macros  7.0 SECS

