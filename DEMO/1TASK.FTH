\ mtask demo
NEEDS DUMP FROM DSK1.TOOLS
NEEDS FORK FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC 

INIT-MULTI
( word to  create a task in heap and FORK)
: TASK:  ( size -- )  MALLOC DUP FORK CONSTANT ;

USIZE TASK: TASK1

HEX
DEAD CONSTANT $DEAD 
BEEF CONSTANT $BEEF 

\ fill and empty the stack 
DECIMAL 
: DEADS   0 0 AT-XY ." DEAD "   10 0 DO $DEAD   LOOP   500 MS ;
: BEEFS   0 0 AT-XY ." BEEF "   10 0 DO $BEEF   LOOP   500 MS ;
: ZEROS   0 0 AT-XY ." zero "   10 0 DO 0       LOOP   500 MS ;
: DROPS   0 0 AT-XY ." drop "   10 0 DO DROP    LOOP   500 MS ;  

\ show the round-robin task time in uS
: .PULSE   TMR@ PAUSE TMR@ - ABS  213 10 */  U. ." uS" ;

\ fill and clear data stack so it can be seen in debugger
: STKTHING
          100 TPAD !  \ move task's pad above root task'S pad
          BEGIN
            DEADS DROPS 
            ZEROS DROPS
            BEEFS DROPS 
            PAUSE
          AGAIN ;     \ *NOTE* Task is looping forever 

' STKTHING TASK1 ASSIGN

\ To start:
\ MULTI <ENTER>
\ TASK1 WAKE <ENTER>
\ .PULSE shows the round-robin time in micro-seconds 
\ (look at memory address >2000..2500 in debugger to see TASK1 stack



