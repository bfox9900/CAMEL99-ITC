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
\ show the round-robin task time in uS. (TMR is 21.3 uS/tick)
: .PULSE   TMR@ PAUSE TMR@ - ABS  213 10   */  6 U.R  ." uS" ;

\ single command to stop a task and goto next task
: STOP    ( -- ) MYSELF SLEEP PAUSE ;

\ re-entrant up counter
: UPCOUNTER ( col row end start -- )
            ?DO
              2DUP AT-XY
              I 8 U.R
              PAUSE
            LOOP
            2DROP ;

\ re-entrant up counter
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


: COUNTER2              \ hex counter
            164 TPAD !
            HEX
            9 0 [ HEX ] 1FF 0 DNCOUNTER
            STOP ;

DECIMAL
: COUNTER3              \ perpetual binary counter
            196 TPAD !
            2 BASE !
            BEGIN
              20 0 256 0 UPCOUNTER
            AGAIN ;

: PULSER                \ show round robin time
            220 TPAD !
            DECIMAL
            BEGIN
              31 0 AT-XY
              PAUSE .PULSE
              500 MS
              [ HEX ] 83D6 OFF  \ kill screen time-out
              [ DECIMAL ]
            AGAIN ;

' COUNTER1 TASK1 ASSIGN
' COUNTER2 TASK2 ASSIGN
' COUNTER3 TASK3 ASSIGN
' PULSER   TASK4 ASSIGN

: RUN
     0  C/L@ BL VFILL \ erase top line of screen
     C/L@ VTOP !     \ set top of screen to 2nd line
     PAGE 
     CR ."   MULTI-TASKING VDP I/O DEMONSTRATION"
     CR ." ---------------------------------------"
     CR ." 3 counter tasks in BASE 10,16 and 2"
     CR ." 1 pulse task, shows round robin"
     CR ." time in micro-seconds"
     CR
     CR ." Shows how tasks can write to screen"
     CR ." using standard screen words."
     CR
     CR ." Console is active."
     CR
     CR ." When counters stop use RESTART to"
     CR ." run them again. WAKE will crash!"

     MULTI
     TASK4 WAKE
     TASK1 WAKE
     TASK2 WAKE
     TASK3 WAKE ;  

