\ mtask spawn tasks demo  updated for V2.5 Feb 2020

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS FORK   FROM DSK1.MTASK99
NEEDS .TASKS FROM DSK1.MTOOLS

INIT-MULTI

\ create a task in heap, fork it, assign Execution token and run it
: SPAWN  ( xt -- ) USIZE MALLOC DUP >R FORK  R@ ASSIGN  R> WAKE ;

HEX 10 CONSTANT STKSIZE  \ each task has ONLY 20 cells for each stack

VARIABLE X   \ used to test if tasks are running

: DROPS   ( n --)  0 DO DROP PAUSE LOOP ; \ drop items from the stack

: STKTHING   \ fill and clear data stack so it can be seen in debugger
          BEGIN
            STKSIZE 0 DO PAUSE DEAD  LOOP
            STKSIZE DROPS

            STKSIZE 0 DO PAUSE BEEF  LOOP
            STKSIZE DROPS
            1 X +!
          AGAIN ;

\ create and wake n tasks.
VARIABLE #TASKS

: TASKS  ( n -- )
         DUP #TASKS !
         0 DO
          CR ." Spawning task "  I .
          ['] STKTHING SPAWN
        LOOP ;

: KILLALL
         SINGLE
         USIZE #TASKS @ *  MFREE
         INIT-MULTI  ;

DECIMAL

: RUN    30 TASKS  MULTI ;

: HELP
PAGE
CR ." TASK DEMO with 30 tasks"
CR ." ----------------------- "
CR ." Type HELP to see this screen."
CR ." SINGLE will stop multi-tasking"
CR ." MULTI will start multi-tasking"
CR
CR  ." Type  RUN to start 25 tasks"
CR ." .TASKS  to see task list"
CR
CR ."  X ?  to see X increment"
CR
CR
CR ." MONITOR to see round-robin time"
CR ." Hold FCTN 4 to stop MONITOR"
;

HELP
