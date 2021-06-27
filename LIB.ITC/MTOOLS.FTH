\ multi-tasker tools

\ These tools are used to evaluate task system performance
\ and control tasks.

: PULSE  ( -- n)  \ returns round robin transit time
         TMR@ PAUSE TMR@ - ABS ;

: .AWAKE ( ? -- ) IF ." awake"  ELSE ." sleep"  THEN ;

: .LOC   ( adr -- ) LOCAL @ U. SPACE ; \ print local variable

: .TASK  ( pid -- )
         HEX
         CR DUP >R U. SPACE
         R@ 'SP .LOC
         R@ 'RP .LOC
         R@ 'IP .LOC
         R> TFLAG LOCAL @ .AWAKE ;

: .HDR  ( -- )
         CR ." PID   Pstk  Rstk   IP   Status
         CR ." ----  ----  ----  ----  ------" ;

\ NEXTJOB steps through the linked list of jobs
\ It's actually reading R13 in each workspace
\ which is aliased as TLINK
: NEXTJOB ( pid -- pid') TLINK LOCAL @ ;

: .TASKS ( -- )
       .HDR
       1 >R    \ intial count is 1 (USER0)
       MYSELF
       BEGIN
            NEXTJOB DUP MYSELF <>
       WHILE
            DUP .TASK
            R> 1+ >R
       REPEAT
       USER0 .TASK
       DROP DECIMAL
       CR R> .  ."  jobs" \ pull count off Rstack
       CR ." Pulse=" PULSE . ;
DECIMAL
: MONITOR  ( -- )
           CR VROW 2@     \ get x,y
           BEGIN
             2DUP AT-XY ." Pulse: " PULSE .
             1000 MS
             ?TERMINAL
           UNTIL
           2DROP ;

: JOBCOUNT  ( -- n )
       1 >R                     \ counter on return stack
       MYSELF
       BEGIN
          NEXTJOB DUP MYSELF <> \ am I back to myself?
       WHILE
           R> 1+ >R             \ inc counter on rstack
       REPEAT
       DROP
       R> ;

: STOPALL ( -- )
       0 >R
       MYSELF
       BEGIN
          NEXTJOB DUP MYSELF <> \ am I back to myself?
       WHILE
           DUP SLEEP
           R> 1+ >R             \ increment the job counter variable
       REPEAT
       DROP
       CR R> . ."  jobs stopped" ;

: WAKEALL ( -- )
       0 >R
       MYSELF
       BEGIN
          NEXTJOB DUP MYSELF <>  \ am I back to myself?
       WHILE
           DUP WAKE              \ wake the task
           R> 1+ >R              \ increment the job counter
       REPEAT
       DROP
       CR R> .  ."  jobs awaken" ;


: MAPTASKS ( xt -- )
       0 >R                      \ COUNTER on R stack
       MYSELF
       BEGIN
          NEXTJOB DUP MYSELF <>  ( -- xt task ?)
       WHILE
           2DUP SWAP  ( -- xt task task xt )
           EXECUTE    \ do the XT action on the task
           R> 1+ >R              \ increment the job counter
       REPEAT
       2DROP
       CR R> . ."  Tasks updated" ;

: XT' ( -- XT)
    STATE @
    IF  '  POSTPONE LITERAL
    ELSE '
    THEN ;
