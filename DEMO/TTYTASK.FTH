\ ALTERNATE workspace console

*does_not_work*

NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- pid )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: USER1

: CHANGEOVER  \ change control to TTYTASK, sleep USER0
          SINGLE
          100 USER1 TPAD LOCAL !
          ['] QUIT USER1 ASSIGN
          USER0 SLEEP
          USER1 WAKE
          PAUSE ;
