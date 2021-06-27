\ Conditional compilation
CR .( [IF] [ELSE] [THEN])
NEEDS COMPARE FROM DSK1.COMPARE
: [ELSE] ( -- )
       1                               \ level
       BEGIN
          BL PARSE-WORD DUP
       WHILE                                 \ level adr len
         2DUP S" [IF]" COMPARE 0=
         IF         \ level adr len
             2DROP 1+                        \ level'
         ELSE                                \ level adr len
            2DUP S" [ELSE]" COMPARE 0=
            IF    \ level adr len
                2DROP 1- DUP IF 1+ THEN      \ level'
            ELSE                             \ level adr len
                S" [THEN]" COMPARE 0=
                IF                           \ level
                   1-                        \ level'
                THEN
            THEN
         THEN ?DUP 0= IF EXIT THEN          \ level'
         BL PARSE-WORD
       REPEAT
       2DROP                                \ level
;

: [IF]   0= IF [ELSE] THEN ; IMMEDIATE
: [THEN] ; IMMEDIATE

\ * test code *
FALSE [IF]  ." Test #1 failed!"
[ELSE]  ." Test#1 passed"
[THEN]

TRUE  [IF]  ." Test#2 passed"
[ELSE]  ." Test #2 failed!"
[THEN]
