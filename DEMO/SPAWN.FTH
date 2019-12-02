\ mtask spawn tasks demo

\ commands to RUN  the demo
\ DECIMAL 42 TASKS ( 42 is the maximum safe number)
\ MULTI
\ .TASKS
\ X ? ( test if the variable is incrementing)

NEEDS DUMP FROM DSK1.TOOLS   \ for debugging etc.
NEEDS FORK FROM DSK1.MTASK99
NEEDS .TASKS FROM DSK1.MTOOLS

INIT-MULTI

\ create a task in heap, fork it, assign Execution token and run it
: SPAWN  ( xt -- )
         USIZE MALLOC ( pid)
         DUP >R FORK
         R@ ASSIGN
         R> WAKE ;

HEX 10 CONSTANT STKSIZE

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
         0 DO  ['] STKTHING SPAWN  LOOP ;

: KILLALL
         SINGLE
         USIZE #TASKS @ *  MFREE
         INIT-MULTI ;

DECIMAL
