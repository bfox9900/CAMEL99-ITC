\ mtask demo

\ This demo let's you leave the Forth workspace and run from
\ a different workspace.

NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

\ 8300 CONSTANT USERO

: WAIT    BEGIN KEY? UNTIL  ABORT ;

  USIZE TASK: USER1      ' WAIT USER1 ASSIGN

\ setup the appropriate user variables in USER1
\ valus   PID    var-name
\ -----   ---    ---------
  0 0    USER1     VROW LOCAL 2!
  TIB 0  USER1  'SOURCE LOCAL 2!

: >USER1  \ change control to TTYTASK, sleep USER0
        MULTI
        USER1 WAKE
        MYSELF SLEEP PAUSE

        SINGLE
;
