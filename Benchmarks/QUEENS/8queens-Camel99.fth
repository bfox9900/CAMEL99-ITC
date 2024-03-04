\ http://www.forth.org/fd/FD-V02N1.pdf
\ VOCABULARY nqueens ALSO nqueens DEFINITIONS

\ Camel99 Forth HARNESS
INCLUDE DSK1.UDOTR
INCLUDE DSK1.ELAPSE 
: ++    POSTPONE 1+! ; IMMEDIATE 

\ replaced original arrays with Camel99 arrays
INCLUDE DSK1.ARRAYS 


8 CONSTANT queens

\ Nqueen solution from FD-V02N1.pdf
\  : 1array CREATE 0 DO 1 , LOOP DOES> SWAP CELLS + ;

    queens ARRAY a \ a,b & c: workspaces for solutions
 queens 2* ARRAY b
 queens 2* ARRAY c
    queens ARRAY x \ trial solutions

: init   
  queens     0 DO 1 I a !  LOOP
  queens 2*  0 DO 1 I b !  LOOP
  queens 2*  0 DO 1 I c !  LOOP 
  queens     0 DO 1 I x !  LOOP
;    

init 

: safe ( c i -- n )
  SWAP
  2DUP - queens 1- + c @ >R
  2DUP + b @ >R
  DROP a @ R> R> * * ;

: mark ( c i -- )
  SWAP
  2DUP - queens 1- + c 0 SWAP !
  2DUP + b 0 SWAP !
  DROP a 0 SWAP ! ;

: unmark ( c i -- )
  SWAP
  2DUP - queens 1- + c 1 SWAP !
  2DUP + b 1 SWAP !
  DROP a 1 SWAP ! ;

VARIABLE tries
VARIABLE sols

: .cols queens 0 DO I x @ 1+ 5 .R LOOP ;
: .sol ." Found on try " tries @ 6 .R .cols CR ;

: try
  queens 0
  DO 1 tries +!
     DUP I safe
     IF DUP I mark
	DUP I SWAP x !
    DUP queens 1- < IF DUP 1+ RECURSE ELSE sols ++  .sol THEN
	DUP I unmark
     THEN
  LOOP DROP ;

: GO 
  0 tries ! 
  CR 0 try 
  CR sols @ . ." solutions Found, for n = " queens . ;

CR .( Type:  ELAPSE GO )  \ runs in 43 seconds 
