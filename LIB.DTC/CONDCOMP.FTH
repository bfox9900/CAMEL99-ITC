\ Conditional compilation

\ INCLUDE DSK1.TOOLS.F

: COMPARE ( a1 n1 a2 n2 -- -1|0|1 ) \  0 = match, -1 = a1<a2, 1 = a1>a2
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS ?DO                ( a1)
        COUNT  I C@  - ( a1 diff)
        DUP IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT THEN         ( a1 diff)
        DROP                  ( a1)
    LOOP DROP                 ( )
    R>  DUP IF  0> 1 OR  THEN   \  2's complement arith.
;

: [ELSE] ( -- )
    1
\    BEGIN                                  \ level
       BEGIN BL PARSE-WORD DUP
       WHILE                                 \ level adr len
         2DUP S" [IF]" COMPARE 0= IF         \ level adr len
             2DROP 1+                        \ level'
          ELSE                               \ level adr len
            2DUP S" [ELSE]" COMPARE
            0= IF    \ level adr len
                2DROP 1- DUP
                IF 1+ THEN      \ level'
            ELSE                             \ level adr len
                S" [THEN]" COMPARE
                0= IF     \ level
                   1-                        \ level'
               THEN
             THEN
          THEN ?DUP 0= IF EXIT THEN          \ level'
       REPEAT 2DROP                          \ level
\     REFILL  0= UNTIL                          \ level
     DROP
; IMMEDIATE

: [IF]   ( flag -- ) 0= IF POSTPONE [ELSE] THEN ; IMMEDIATE
: [THEN] ( -- ) ; IMMEDIATE
