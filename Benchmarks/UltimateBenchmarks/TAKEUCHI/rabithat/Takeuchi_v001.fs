\ Takeuchi function benchmark
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
NEEDS ELAPSE FROM DSK1.ELAPSE 

\ ROLL is not in the Camel99 kernel 
: ROLL \ nn..n0 n -- nn-1..n0 nn ; 6.2.2150
  DUP>R PICK
  SP@ DUP CELL+ R> 1+ CELLS MOVE DROP ;

\ >=  is not in the kernel   
: >=   S" 1- > " EVALUATE ; IMMEDIATE

\ ( x y z -- x y z boolean)
: NOT_Y<X?  1 PICK 3 PICK >= ;

\ ( x y z -- z )
: ONLY_Z SWAP DROP SWAP DROP ;

\ ( x y z -- x y z x-1 y z)	 
: TAKX 2 PICK 1- 2 PICK 2 PICK ;

\ ( x y z result1 -- x y z result1 y-1 z x)
: TAKY 2 PICK 1- 2 PICK 5 PICK ;

\ ( x y z result1 result2 -- result1 result2 (z-1) x y)
\ : TAKZ 2 ROLL 1- 4 ROLL 4 ROLL ; 
: TAKZ     ROT 1- >R  2SWAP  R> -ROT ;

\ ( x y z -- result )
: TAK NOT_Y<X? 
   IF ONLY_Z 
   ELSE TAKX RECURSE 
        TAKY RECURSE 
        TAKZ RECURSE RECURSE 
   THEN ;

\ 18 12 6 TAK   is the benchmark arguments 