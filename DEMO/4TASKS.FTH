\ 4tasks  mulit-tasking demo with numeric printing

INCLUDE DSK1.TOOLS
INCLUDE DSK1.MTASK99
INCLUDE DSK1.UDOTR    \ Right justified number printing
INCLUDE DSK1.MALLOC   \ Malloc removed from kernel in V2.0
INCLUDE DSK1.VALUES

INIT-MULTI

\ Use primitives to create a word that dynamically creates a task
\ wakes it and returns the task PID (program identifier)
: SPAWN  ( xt -- pid) USIZE MALLOC DUP>R FORK  R@ ASSIGN R@ WAKE R>  ;

\ used to hold Pid of each task
0 VALUE TASK1
0 VALUE TASK2
0 VALUE TASK3
0 VALUE TASK4

DECIMAL
\ get the round-robin task time in 9901 timer ticks. (21.2uS per tick)
: PULSE@  ( ) TMR@ PAUSE TMR@ - ABS ;

\ print n timer ticks in milli-seconds
: .MS    ( n -- )  213 10000  */  4 U.R  ." mS" ;


\ single command to stop a task and goto next task
: STOP    ( -- ) MYSELF SLEEP PAUSE  ;

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
            100 TPAD !  \ set task's PAD OFFSET from HERE
            0 0 1000 0 UPCOUNTER
            STOP  ;

DECIMAL
: COUNTER2              \ hex counter
            HEX
            200 TPAD !
            9 0  512 0 DNCOUNTER
            STOP ;

DECIMAL
: COUNTER3            \ perpetual binary counter
            300 TPAD !
            2 BASE !  \ print in binary
            BEGIN
              20 0 256 0 UPCOUNTER
            AGAIN ;

HEX 83D6 CONSTANT SCR_TIME_OUT

DECIMAL
: PULSER  \ show round robin time
            400 TPAD !
            DECIMAL
            BEGIN
              30 0 AT-XY ." t=" PULSE@  .MS
              1000 MS
              SCR_TIME_OUT  OFF  \ kill screen time-out
            AGAIN ;

: SPAWN-TASKS
    ['] COUNTER1 SPAWN TO TASK1
    ['] COUNTER2 SPAWN TO TASK2
    ['] COUNTER3 SPAWN TO TASK3
    ['] PULSER   SPAWN TO TASK4
;

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
    SPAWN-TASKS  ;
