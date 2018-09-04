\ multi-tasker tools
 
\ These tools are used to evaluate system performance
\ with tasks running.
 
: PULSE  ( -- n)  \ returns round robin transit time
         TMR@ PAUSE TMR@ - ABS ;
 
: .AWAKE        ( ? -- ) IF ." awake"  ELSE ." sleep"  THEN ;
 
: .LOC  ( adr -- ) LOCAL @ U. SPACE ;
 
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
 
: .TASKS ( -- )
       .HDR
       1 >R    \ intial count is 1 (USER0)
       MYSELF
       BEGIN
            TLINK LOCAL @  DUP MYSELF <>
       WHILE
            DUP .TASK
            R> 1+ >R
       REPEAT
       USER0 .TASK
       DROP DECIMAL
       CR R> .  ."  jobs"    \ pull count off Rstack
       CR ." Pulse=" PULSE . ;

: MONITOR  ( -- )
           CR VROW 2@   \ get x,y
           BEGIN
             2DUP AT-XY ." Pulse: "PULSE .
             50 MS
             ?TERMINAL
           UNTIL 
           2DROP ;
 
