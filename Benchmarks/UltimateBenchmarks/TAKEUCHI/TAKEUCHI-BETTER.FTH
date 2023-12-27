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
\ Equivalent Forth definition of Takeuchi function:  CAMEL99 Forth

NEEDS .S     FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS 3RD    FROM DSK1.3RD4TH

DECIMAL
: >=   S" 1- > " EVALUATE ; IMMEDIATE
: 2ROT   ( d d2 d3 -- d2 d3 d) 2>R 2SWAP 2R> 2SWAP ;

: NOT_Y<X?  ( x y z -- x y z ?) OVER  3 PICK >= ;

: ONLY_Z ( x y z -- z ) NIP NIP  ;

: TAKX 2 ( x y z -- x y z x-1 y z) PICK 1- 3RD 3RD ;

\ ( x y z result1 -- x y z result1 y-1 z x)
: TAKY   2 PICK 1- 2 PICK 5 PICK ;

\ ( x y z result1 result2 -- result1 result2 (z-1) x y)
: TAKZ   ROT 1- 0 2ROT ROT DROP ;

\ BENCHMARK values:  DECIMAL 18 12 6 ELAPSE TAK
: TAK  ( x y z -- result )  \ 67.21 seconds on TI-99
      NOT_Y<X?
      IF ONLY_Z
      ELSE TAKX RECURSE
           TAKY RECURSE
           TAKZ RECURSE
           RECURSE
      THEN ;

\ ======================================================

: ONLY_Z ( x y z -- z ) NIP NIP ;  \ using NIP instead

: TAK2  ( x y z -- result )  \ 61.93 seconds
      NOT_Y<X?
      IF ONLY_Z
      ELSE TAKX RECURSE
           TAKY RECURSE
           TAKZ RECURSE
           RECURSE
      THEN ;


\ faster version uses 3RD & 4TH  6TH
: NOT_Y<X?  ( x y z -- x y z ?) OVER  4TH >= ;
: TAKX 2 ( x y z -- x y z x-1 y z) PICK 1- 3RD 3RD ;
: TAKY   ( x y z result1 -- x y z result1 y-1 z x) 3RD 1-  3RD 6TH ;

\ ( x y z result1 result2 -- result1 result2 (z-1) x y)
: TAKZ   ROT 1- 0 2ROT ROT DROP ;

: TAK3  ( x y z -- result )  \ 54.45 seconds (-14%)
      NOT_Y<X?
      IF ONLY_Z
      ELSE TAKX RECURSE
           TAKY RECURSE
           TAKZ RECURSE
           RECURSE
      THEN ;

: TAK4  ( x y z -- result )  \ 46.16 seconds
      OVER 4TH >=           \ remove needless factoring
      IF NIP NIP
      ELSE TAKX RECURSE
           TAKY RECURSE
           TAKZ RECURSE
           RECURSE
      THEN ;

