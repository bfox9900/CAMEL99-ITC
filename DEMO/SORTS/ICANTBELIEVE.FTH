\ I CAN'T BELIEVE IT CAN SORT  SORT  :-)

DECIMAL
10 TO SIZE
REVERSED

0 VALUE A[]

: ]A@  ( n i -- n') CELLS A[] + @ ;
: ]A!  ( n i -- )  CELLS A[] + ! ;

: ICANT ( addr len )
    TO SIZE
    TO A[]
    SIZE 0
    DO  SIZE 0
        DO
           I ]A@  J ]A@ >
           IF
              I ]A@  J ]A@   I ]A! J ]A!
           THEN
        LOOP
    LOOP
;

: RUN  Q[] SIZE ICANT ;

\ need to store the bounds because DO leaves shit on the data stack
CREATE X  0 , 0 ,

: ICANT ( addr len )
    CELLS BOUNDS  2DUP X 2!
    DO  X 2@
        DO
           I @  J @ >
           IF
              I @  J @   I !  J !
           THEN
        2 +LOOP
    2 +LOOP
;

: RUN  Q[] SIZE ICANT ;
