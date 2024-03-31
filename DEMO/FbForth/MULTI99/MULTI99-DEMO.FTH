\ MULTI99 DEMO CODE for FbForth on TI-99  Brian Fox 

0 VARIABLE TASK1   USIZE ALLOT
0 VARIABLE TASK2   USIZE ALLOT
0 VARIABLE TASK3   USIZE ALLOT

TASK1 FORK
TASK2 FORK
TASK3 FORK

0 VARIABLE X
0 VARIABLE Y

: THING1  BEGIN   1 X +!  YIELD AGAIN ;
: THING2  BEGIN  -1 Y +!  YIELD AGAIN ;

\ multi-tasking delay must include a YIELD
: DELAYS  ( n --) 0 DO  YIELD LOOP ;

\ stop a task and giveup control
: HALT    ( PID --) SLEEP YIELD ;

\ runs five times and then goes to sleep
: THING3
   5 0 DO
       100 DELAYS
       0 0 GOTOXY ." TASK3 is butting in here... :-)"
       30 DELAYS
       0 40 BL VFILL
  LOOP
  0 0 GOTOXY ." Task3 is asleep now."
  ME HALT ;

' THING1 TASK1 ASSIGN
' THING2 TASK2 ASSIGN
' THING3 TASK3 ASSIGN

TASK1 WAKE
TASK2 WAKE
TASK3 WAKE

\ We need a YIELD loop to run the tasks.
\ Could be build into KEY
: TESTLOOP
    PAGE ." TASK1 INC X, TASK2 DEC Y"
    BEGIN
           0 2 GOTOXY  X @ U. 4 SPACES  Y @ U.
          YIELD
          ?TERMINAL
    UNTIL ;
