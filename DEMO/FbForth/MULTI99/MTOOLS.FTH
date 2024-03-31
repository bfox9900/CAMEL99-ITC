\ MULTI99 TOOLS      APR 29 Brian Fox
\ taken from Camel99 Forth
\ These tools are used to evaluate task system performance
\ and control tasks.
HEX 83D6 CONSTANT STO  \ screen time out counter

DECIMAL
: MS    0 DO   100 0 DO YIELD LOOP   LOOP ;
: 2/    1 SRA ;

: PULSE  ( -- n)  \ returns coarse round robin transit time
         STO @ YIELD  STO @ - ABS  2/ ;

: .AWAKE ( ? -- ) IF ." awake"  ELSE ." sleep"  ENDIF  ;

: .TASK  ( pid -- )
         HEX
         DUP >R
         CR ." PID: " U. SPACE
         CR ." SP0: " R TASK-SP0 U.
         CR ." RP0: " R TASK-RP0 U.
         CR R> TFLAG LOCAL @ .AWAKE ;

\ We need a YIELD loop to run the tasks.
\ Could be built into a new version of KEY
: TESTLOOP
    PAGE ." TASK1 INC X, TASK2 DEC Y"
    BEGIN
           0 2 GOTOXY  X @ U. 4 SPACES  Y @ U.
           0 4 GOTOXY ." Pulse: "  PULSE U.
          YIELD
          ?TERMINAL
    UNTIL ;
