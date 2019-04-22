\ mtask demo
NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: TASK1

HEX
: DROP16  ( n --)  2DROP 2DROP 2DROP 2DROP
                   2DROP 2DROP 2DROP 2DROP  ;

\ show the round-robin task time in uS
: .PULSE   TMR@ PAUSE TMR@ - ABS  213 10 */  U. ." uS" ;


\ fill and clear data stack so it can be seen in debugger
: STKTHING
          HEX
          80 TPAD !  \ move task's pad above root task'S pad
          20 0 AT-XY
          VROW 2@        \ fetch x,y
          BEGIN
            2DUP AT-XY ." TASK1   "

            10 0 DO DEAD  LOOP 100 MS
            DROP16 100 MS

            10 0 DO BEEF  LOOP 100 MS
            DROP16 100 MS

            10 0 DO 0     LOOP 100 MS
            DROP16 100 MS
            2DUP AT-XY DECIMAL  .PULSE
            HEX 200 MS
            PAUSE
          AGAIN ;

' STKTHING TASK1 ASSIGN

\ To start:
\ MULTI <ENTER>
\ TASK1 WAKE <ENTER>
\ (look at memory address >2000..2100 in debugger to see TASK1 stack



