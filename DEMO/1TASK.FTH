\ mtask demo
INCLUDE DSK1.MTASK99.F

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK  CONSTANT ;

USIZE TASK: TASK1

HEX

: STKTHING   \ fill and clear data stack so it can be seen in debugger
          BEGIN
            FFCF FFA0 DO I     LOOP 100 MS
            FFCF FFA0 DO DROP  LOOP  50 MS
            FFCF FFA0 DO 0     LOOP 100 MS
            FFCF FFA0 DO DROP  LOOP
            PAUSE
          AGAIN ;

' STKTHING TASK1 ASSIGN

\ show the round-robin task time in uS
: PULSE.   TMR@ PAUSE TMR@ - ABS  213 10 */  U. ." uS" ;


