\  Fibonacci series using more Forth tricks

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
       0 1 ROT 0
       ?DO
          BOUNDS
       LOOP
       DROP ;

: FIBZ ( N>0 -- X Y ) 1- 0 1 ROT 0 DO TUCK + LOOP ;
