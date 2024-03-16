\ SPAWN.FTH for Camel99 Forth Mar 2024 Brian Fox 

\ SPAWN is very handy for creating a task area at the start of your program.
\ This save space in the dictionary and in the binary image if you save one.
\ SPAWN make the task area USIZE (106 bytes) which is the default size.

NEEDS FORK FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC 

\ allocate task space in heap, fork it, assign Execution, return PID
: SPAWN  ( xt -- pid)  USIZE MALLOC DUP>R FORK  R@ ASSIGN  R> ;

\ Usage example 
\ : BGCOUNTER    0 BEGIN PAUSE  1+  AGAIN ;
\ : DOWNCOUNTER  0 BEGIN PAUSE 1-  AGAIN ;

\ VARIABLE TASK1

\ : RUN   \ MAIN PROGRAM 
\    INIT-MULTI                      \ reset the multi-tasker (for program images)  
\    MULTI                           \ start up the multi-tasker  
\    ['] BGCOUNTER SPAWN  TASK1 !    \ store the PID in a variable 
\    ['] DOWNCOUNTER SPAWN WAKE      \ WAKE this one right away. (can't stop it)
    
\ Wake can WAKE/SLEEP/RESTART this because it is in a variable 
\    TASK1 @ WAKE                    
\    CR ." 2 tasks running..."    
\ ;     
    
    
