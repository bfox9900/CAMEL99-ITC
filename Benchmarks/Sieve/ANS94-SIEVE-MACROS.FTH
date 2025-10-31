\ ANSified Sieve of Eratosthenes by Leo Wong
\ from http://www.murphywong.net/hello/01234th.htm#marker

\ Used Leo Wong's MACRO  word to speed up short definitions

\ CAMEL99 Harness
NEEDS ELAPSE FROM DSK1.ELAPSED
NEEDS VALUE FROM DSK1.VALUES

NEEDS MACRO FROM DSK1.MACROS

MACRO UNDER+   " ROT + SWAP" ( a b c --a' b )
MACRO SQUARED  " DUP *"      ( a -- a^2)

\ --------------------------------------------
DECIMAL
8192 CONSTANT SIZE  \ test this many odd numbers
CREATE FLAGS SIZE CHARS ALLOT  \ odd numbers

HERE CONSTANT END-FLAGS  \ address after the list

MACRO ODD " 2* 3 +"  ( u -- n)  \ number n of flag u


0 VALUE SIFT  \ to sift or not to sift

\ calculate offset of prime**2
MACRO NEXT-SQUARE  " DUP SQUARED 2*  SWAP 6 * +  3 +"  ( u1 -- u2 )

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
