\ ONETASK.FTH  simple counter DEMO   Apr 20 2021  Brian fox
\ Puts a running counter on top corner of your screen

NEEDS FORK  FROM DSK1.MTASK99
NEEDS U.R   FROM DSK1.UDOTR

\ make a memory space for our task
CREATE TASK1   USIZE ALLOT \ USIZE is the size of one "user area"

\ FORK copies Forth's entire workspace into TASK1's workspace
TASK1 FORK

VARIABLE X   \ A simple global variable

DECIMAL      \ make the compiler use decimal arithmetic

: COUNTER1 ( -- )    \ A background job for the computer
       DECIMAL       \ make this job use decimal math
       200 TPAD !    \ give this task a PAD 200 bytes above Forth's PAD
       BEGIN
          X 1+!      \ increment x

          33 0 AT-XY \ put THIS task's cursor a column 33, row 0
                     \ each task has its own VROW and VCOL variables

          X @ 6 U.R  \ fetch X and print right justified, 6 columns

          100 MS     \ Wait 100 milli-seconds.
                     \ MS gives time to other tasks while it waits
       AGAIN ;       \ jobs must always loop or do SLEEP PAUSE

' COUNTER1 TASK1 ASSIGN   \ assign COUNTER1 to TASK1
CR
CR .( =====================)
CR .( Demo Instructions:)
CR
CR .( Type  MULTI  to enable tasking)
CR .( Type  TASK1 WAKE )
CR .( counter appears upper left)
CR .( X OFF resets variable)
CR .( TASK1 SLEEP)
CR .( counter stops)
CR .( SINGLE  disables all tasking)
CR
