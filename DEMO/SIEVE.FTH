\ Sieve of Erathosenes in Forth

NEEDS ELAPSE FROM DSK1.ELAPSE

\ array fetch and store as text macros run 19% faster
 : [@] ( n addr --�n ) S" + C@" EVALUATE ; IMMEDIATE
 : [!] ( n addr -- )   S" + C!" EVALUATE ; IMMEDIATE

\ : [@] ( n addr --�n )  + C@ ;
\ : [!] ( n addr -- )     + C! ;

\ Squared operation text macro for clarity
: ^2  ( n -- n^2)    S" DUP *" EVALUATE ; IMMEDIATE

: ERASE  ( addr n -- ) 0 FILL ;

HEX
: FREEMEM  ( -- n) FF00 HERE - ;
: ?MEM     ( n -- )  FREEMEM OVER < ABORT" Out of memory" ;

: SEEPRIMES ( -- )
        CR ." Primes: "
        2 DO
            I HERE [@] 0= IF I . THEN
            ?TERMINAL ABORT" Primes halted"
        LOOP ;

\ byte array uses unallocated memory at HERE
DECIMAL
: PRIMES ( n -- )
        ?MEM
        CR ." Running " DUP U. ." primes"
        HERE OVER ERASE
        1 0 HERE [!]       \ mark as prime like 'C' version
        1 1 HERE [!]
        2                  \ start at 2
        BEGIN
           2DUP ^2 >
        WHILE
           DUP HERE [@] 0=
           IF  2DUP ^2
               DO
                  1 I HERE [!]
               DUP +LOOP
           THEN
           1+
        REPEAT
        CR ." Complete."
        .ELAPSED
        CR
        DROP
        CR ." Press ENTER to see primes:" KEY 13 =
        IF   SEEPRIMES   THEN
;

: RUN  10000 TICKER OFF PRIMES ;
