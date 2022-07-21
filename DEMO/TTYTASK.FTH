\ mtask demo
NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

\ 8300 CONSTANT USERO

  USIZE TASK: USER1      ' ABORT USER1 ASSIGN

\ setup the appropriate user variables in USER1
\ valus   PID    var-name
\ -----   ---    ---------
  0 0    USER1     VROW LOCAL 2!
  TIB 0  USER1  'SOURCE LOCAL 2!
  


: CHANGEOVER  \ change control to TTYTASK, sleep USER0
          USER1 WAKE
          USER0 SLEEP  PAUSE SINGLE 
 ;


