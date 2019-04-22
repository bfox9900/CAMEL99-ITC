\ mtask demo
NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: TTYTASK

: CHANGEOVER  \ change control to TTYTASK, sleep USER0
          ['] QUIT TTYTASK ASSIGN
          TTYTASK WAKE
          USER0 SLEEP
          MULTI ;

          
