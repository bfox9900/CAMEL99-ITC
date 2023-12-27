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

: >=   S" 1- >" EVALUATE ; IMMEDIATE

\ ------------------------------------------------
INCLUDE DSK1.3RD4TH 

: TAK  ( x y z -- result ) 
    OVER 4TH >=  IF NIP NIP  EXIT THEN 
    3RD 1-  3RD 3RD    RECURSE 
    3RD 1-  3RD 5 PICK RECURSE 
    ROT 1- >R  2SWAP  R> -ROT RECURSE 
    RECURSE 
;

: TAKTEST   18 12 6 TAK . ;

INCLUDE DSK1.JIT

JIT: TAKJIT  ( x y z -- result ) 
    OVER 4TH >=  IF NIP NIP  EXIT THEN 
    3RD 1-  3RD 3RD    RECURSE 
    3RD 1-  3RD 5 PICK RECURSE 
    ROT 1- >R  2SWAP  R> -ROT RECURSE 
    RECURSE 
;JIT


\ 18 12 6 TAK   are the benchmark arguments 