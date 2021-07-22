\ 4tasks  mulit-tasking demo with numeric printing

INCLUDE DSK1.TOOLS
INCLUDE DSK1.MTASK99
INCLUDE DSK1.UDOTR    \ Right justified number printing
INCLUDE DSK1.MALLOC   \ Malloc removed from kernel in V2.0

INIT-MULTI

( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: TASK1
USIZE TASK: TASK2
USIZE TASK: TASK3
USIZE TASK: TASK4

DECIMAL
\ get the round-robin task time in 9901 timer ticks. (21.2uS per tick)
: PULSE@  ( ) TMR@ PAUSE TMR@ - ABS ;

\ print n timer ticks in milli-seconds
: .MS    ( n -- )  213 10000  */  6 U.R  ." mS" ;


\ single command to stop a task and goto next task
: STOP    ( -- ) MYSELF SLEEP PAUSE ;

\ re-entrant up counter
: UPCOUNTER ( col row end start -- )
            ?DO
              2DUP AT-XY I 8 U.R
              PAUSE
            LOOP
            2DROP ;

\ re-entrant down counter
: DNCOUNTER ( col row end start -- )
            SWAP
            ?DO
              2DUP AT-XY
              I 8 U.R
              PAUSE
            -1 +LOOP
            2DROP ;

: COUNTER1              \ decimal counter
            DECIMAL
            132 TPAD !  \ set task's PAD offset from HERE
            0 0 1000 0 UPCOUNTER
            STOP  ;

DECIMAL
: COUNTER2              \ hex counter
            HEX
            164 TPAD !
            9 0  512 0 DNCOUNTER
            STOP ;

DECIMAL
: COUNTER3            \ perpetual binary counter
            196 TPAD !
            2 BASE !  \ print in binary
            BEGIN
              20 0 256 0 UPCOUNTER
            AGAIN ;

HEX 83D6 CONSTANT SCR_TIME_OUT

DECIMAL
: PULSER                \ show round robin time
            220 TPAD !
            DECIMAL
            BEGIN
              30 0 AT-XY ." t=" PULSE@  .MS
              1000 MS
              SCR_TIME_OUT  OFF  \ kill screen time-out
            AGAIN ;

: RUN-TASKS
['] COUNTER1 TASK1 ASSIGN
['] COUNTER2 TASK2 ASSIGN
['] COUNTER3 TASK3 ASSIGN
['] PULSER   TASK4 ASSIGN
  TASK4 WAKE 1000 MS
  TASK1 WAKE 1000 MS
  TASK2 WAKE 1000 MS
  TASK3 WAKE ;

: RUN
     PAGE
     C/L@ VTOP !     \ set top of screen to 2nd line
     PAGE
     CR
     CR ."   MULTI-TASKING VDP I/O DEMONSTRATION"
     CR ." ---------------------------------------"
     CR ." 3 counter tasks in BASE 10,16 and 2"
     CR ." 1 pulse task, shows round robin"
     CR ." time in milli-seconds"
     CR
     CR ." Shows how tasks can write to screen"
     CR ." using standard screen words."
     CR
     CR ." Forth console will be active."
     CR ." You have: TASK1 TASK2 TASK3 TASK4"
     CR ." When counters stop use TASK1 RESTART"
     CR ." to run them again. WAKE will crash!"
     CR
     CR ." Top line of screen is protected"
     CR ." Type WORDS to see this."
     CR
     CR ." Press a key to start the demo" KEY DROP
     MULTI
     RUN-TASKS  ;
