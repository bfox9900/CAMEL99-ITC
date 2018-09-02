\ 4tasks.f  mtask demo with numeric printing

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.MTASK99.F
INCLUDE DSK1.UDOTR.F    \ RIGHT justified number printing

INIT-MULTI

( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: TASK1
USIZE TASK: TASK2
USIZE TASK: TASK3
USIZE TASK: TASK4

DECIMAL
\ show the round-robin task time in uS
: .PULSE   TMR@ PAUSE TMR@ - ABS  213 10 */  6 U.R  ." uS" ;

\ fill and clear data stack so it can be seen in debugger
: COUNTER1
            DECIMAL
            132 TPAD !
            BEGIN
              1000 0
              ?DO
                 0 0 AT-XY  I 5 U.R
              LOOP
            AGAIN ;
HEX
: COUNTER2
            164 TPAD !
            HEX
            FFFF 0 SWAP
            ?DO                                                                           
              9 0 AT-XY  I 5 U.R
           -1 +LOOP
            MYSELF SLEEP
            PAUSE  ;

DECIMAL
: COUNTER3
            196 TPAD !
            2 BASE !
            BEGIN
              256 0
              ?DO
                 20 0 AT-XY  I 9 U.R
              LOOP
            AGAIN ;

: PULSER
            220 TPAD !
            DECIMAL
            BEGIN
              30 0 AT-XY  .PULSE
              250 MS
            AGAIN ;

' COUNTER1 TASK1 ASSIGN
' COUNTER2 TASK2 ASSIGN
' COUNTER3 TASK3 ASSIGN
' PULSER TASK4 ASSIGN

0  C/L@ BL VFILL \ erase top line of screen
C/L @ VTOP !     \ set top of screen to 2nd line

