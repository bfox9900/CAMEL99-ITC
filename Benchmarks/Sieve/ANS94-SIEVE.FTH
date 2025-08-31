\ ANSified Sieve of Eratosthenes by Leo Wong
\ from http://www.murphywong.net/hello/01234th.htm#marker

\ CAMEL99 Harness
NEEDS VALUE FROM DSK1.VALUES
: UNDER+  ( a b c --a' b ) ROT + SWAP ;
: SQUARED ( a -- a^2) DUP * ;

\ --------------------------------------------
DECIMAL
8192 CONSTANT SIZE  \ test this many odd numbers
CREATE FLAGS SIZE CHARS ALLOT  \ odd numbers
HERE CONSTANT END-FLAGS  \ address after the list

: ODD  ( u -- n)  \ number n of flag u
   2* 3 + ;

0 VALUE SIFT  \ to sift or not to sift

\ calculate offset of prime**2
: NEXT-SQUARE  ( u1 -- u2 )
   DUP SQUARED 2*  SWAP 6 * +  3 + ;

\ reset flags of multiples of a prime
: RESET-FLAGS
   ( increment end-address start-address -- )
   DO  0 I C!  \ reset flag of an odd multiple
       DUP     \ duplicate the loop increment
   +LOOP  DROP ;

: SIEVE   ( -- )
   FLAGS SIZE 1 FILL    \ assume numbers are prime
   TRUE TO SIFT         \ yes to sifting
   0                    \ 0 the count of primes
   FLAGS                \ start with first flag
   SIZE 0 DO            \ outer loop
      COUNT IF          \ prime? ; address now next flag
      1 UNDER+          \ add 1 to the count of primes
         SIFT IF
            I NEXT-SQUARE DUP SIZE
               U< IF                \ next square in array?
                 I ODD CHARS        \ loop increment
                 END-FLAGS          \ loop end
                 ROT CHARS FLAGS +  \ loop start
                 RESET-FLAGS        \ inner loop
               ELSE
                 DROP  FALSE TO SIFT
               THEN
         THEN
    THEN
   LOOP
   DROP U. ." Primes" ;

\ code used by BYTE Magazine version
: PRIMES ( -- )
   PAGE ."  10 Iterations"
   10 0 DO CR SIEVE  LOOP
   CR ." Done!"
;
