\ amazing fast queens solution in Forth Rosetta Code author ??   

\ Brought in 3RD4TH library for faster stack words
\ Used 1+! to increment variables 
\ 1.1 seconds faster = 24% faster 

INCLUDE DSK1.ELAPSE
INCLUDE DSK1.3RD4TH 


VARIABLE SOLUTIONS  
VARIABLE NODES

: THIRD ( a b c -- a b c a ) POSTPONE 3RD ;  IMMEDIATE 
: 2OVER ( a b c d -- a b c d a b ) POSTPONE 4TH POSTPONE 4TH ; IMMEDIATE 

: LOWBIT  ( mask -- bit )  DUP NEGATE AND ;
: LOWBIT- ( mask -- bits ) DUP 1- AND ;

: AND3 ( a b c -- a b c a&b&c ) DUP 2OVER AND AND ;

: NEXT3 ( dl dr f qfilebit -- dl dr f dl' dr' f' )
  INVERT >R 
  THIRD R@ AND 2* 1+  
  THIRD R@ AND 2/  
  THIRD R> AND ;

: TRY ( dl dr f -- )
  DUP 
  IF NODES 1+! AND3
    BEGIN ?DUP 
    WHILE
      DUP >R LOWBIT NEXT3 
      RECURSE 
      R> LOWBIT-
    REPEAT
  ELSE SOLUTIONS 1+! 
  THEN DROP 2DROP ;

: QUEENS ( n -- )  
  0 SOLUTIONS ! 
  0 NODES ! 
  CR
  1 OVER LSHIFT 1-  
  -1 DUP ROT TRY 
  . ." QUEENS: " SOLUTIONS @ . ." SOLUTIONS, " NODES @ . ." NODES" ;

CR .( Type: ELAPSE 8 QUEENS ) 
CR .( and be amazed)  


