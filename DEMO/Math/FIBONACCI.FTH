\  Fibonacci series using more Forth tricks

NEEDS ELAPSE  FROM DSK1.ELAPSE

DECIMAL
: FIB0 ( n -- n') \ Naive Forth version
     TICKER OFF
     DUP 2 1 + <
     IF
       DROP 1
     ELSE
        DUP 1 - RECURSE
        SWAP 2 - RECURSE +
     THEN
     .ELAPSED ;

: FIB1 ( n -- n') \ Experienced Forth coder
  TICKER OFF
	DUP 2 >
        IF DUP  1- RECURSE
           SWAP 2- RECURSE +  EXIT
	THEN
	DROP 1 ;

: FIB2 ( n -- n') \ iterated version
      TICKER OFF
      0 1 ROT 0
      ?DO
         OVER + SWAP
      LOOP
      DROP
      .ELAPSED ;

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
