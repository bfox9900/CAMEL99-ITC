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
           I  J <
           IF
           I ]A@  J ]A@   I ]A! J ]A!
           THEN
        LOOP
    LOOP
;
