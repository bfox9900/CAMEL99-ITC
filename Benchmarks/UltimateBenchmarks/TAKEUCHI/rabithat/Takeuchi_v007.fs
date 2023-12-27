\ Takeuchi function benchmark with CAMEL99 Optimizations 
\ ----------------------------------------------------------------------------------------
\
\ Lisp definition of Takeuchi function (Copied from: http://www.ulisp.com/show?1EO1):
\ (defun tak (x y z)
\   (if (not (< y x))
\      z
\     (tak
\      (tak (1- x) y z)
\      (tak (1- y) z x)
\      (tak (1- z) x y))))
	 
\ ----------------------------------------------------------------------------------------
\ Equivalent Forth definition of Takeuchi function:

\ Edited for Camel99 Forth 
NEEDS ELAPSE FROM DSK1.ELAPSE  \ timer 

\ Stuff not in Camel99 kernel 
: ROLL \ nn..n0 n -- nn-1..n0 nn ; 6.2.2150
  DUP>R PICK
  SP@ DUP CELL+ R> 1+ CELLS MOVE DROP ;

: >=   S" 1- >" EVALUATE ; IMMEDIATE

\ ------------------------------------------------
INCLUDE DSK1.3RD4TH 
INCLUDE DSK1.TAILCALL 
\ ( x y z -- x y z boolean)
: NOT_Y<X?   OVER 4TH >= ;

\ ( x y z -- z )
: ONLY_Z     NIP NIP ;

\ ( x y z -- x y z x-1 y z)	 
: TAKX   3RD 1-  3RD 3RD ;

\ ( x y z result1 -- x y z result1 y-1 z x)
: TAKY  3RD 1-  3RD 5 PICK ;

\ ( x y z result1 result2 -- result1 result2 (z-1) x y)
: TAKZ   2 ROLL 1-  4 ROLL 4 ROLL -; 

\ ( x y z -- result )
: TAK NOT_Y<X? 
   IF ONLY_Z 
   ELSE TAKX RECURSE 
        TAKY RECURSE 
        TAKZ RECURSE RECURSE 
   THEN ;

\ 18 12 6 TAK   are the benchmark arguments 