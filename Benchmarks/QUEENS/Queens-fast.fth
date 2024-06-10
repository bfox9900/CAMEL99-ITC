\ amazing fast queens solution in Forth Rosetta Code author ??   

INCLUDE DSK1.ELAPSE

VARIABLE SOLUTIONS  
VARIABLE NODES

: THIRD ( a b c -- a b c a ) 2 PICK ;  
: 2OVER ( a b c d -- a b c d a b ) 3 PICK 3 PICK  ;

: LOWBIT  ( mask -- bit ) DUP NEGATE AND ;
: LOWBIT- ( mask -- bits ) DUP 1- AND ;

: AND3 ( a b c -- a b c a&b&c ) DUP 2OVER AND AND ;

: NEXT3 ( dl dr f qfilebit -- dl dr f dl' dr' f' )
  INVERT >R 
  THIRD R@ AND 2* 1+  
  THIRD R@ AND 2/  
  THIRD R> AND ;

: TRY ( dl dr f -- )
  DUP 
  IF 1 NODES +! AND3
    BEGIN ?DUP 
    WHILE
      DUP >R LOWBIT NEXT3 
      RECURSE 
      R> LOWBIT-
    REPEAT
  ELSE 1 SOLUTIONS +! 
  THEN DROP 2DROP ;

: QUEENS ( n -- )  
  0 SOLUTIONS ! 
  0 NODES ! 
  CR
  1 OVER LSHIFT 1-  
  -1 DUP ROT TRY 
  . ." QUEENS: " SOLUTIONS @ . ." SOLUTIONS, " NODES @ . ." NODES" ;

CR .( Type: ELAPSE 8 QUEENS ) 
CR .( and be amazed)  ( 5.55 seconds )


