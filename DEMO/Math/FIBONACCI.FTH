\  Fibonacci series using more Forth tricks

NEEDS ELAPSE  FROM DSK1.ELAPSE

DECIMAL
: FIB0 ( n -- n') \ Naive Forth version
     DUP 2 1 + <
     IF
       DROP 1
     ELSE
        DUP 1 - RECURSE
        SWAP 2 - RECURSE +
     THEN ;



: FIB1 ( n -- n') \ Experienced Forth coder
	DUP 2 >
        IF DUP  1- RECURSE
           SWAP 2- RECURSE +  EXIT
	THEN
	DROP 1 ;


: FIB2 ( n -- n') \ iterated version
      0 1 ROT 0
      ?DO
         OVER + SWAP
      LOOP
      DROP ;

: FIB3  ( n -- n') \ optimized iterated version
      TICKER OFF
      0 1 ROT 0
      ?DO
         BOUNDS
      LOOP
      DROP
      .ELAPSED ;

: FIBZ ( N>0 -- X Y )
   TICKER OFF
   1- 0 1 ROT 0 DO TUCK + LOOP
   .ELAPSED ;

: .FIB(X) ( n -- n )  CR ." FIB(" DUP .  ." ) ="   TICKER OFF ;

: TEST0    22 .FIB(X) FIB0 .  .ELAPSED ;
: TEST1    22 .FIB(X) FIB1 .  .ELAPSED ;
: TEST2    22 .FIB(X) FIB2 .  .ELAPSED ;
