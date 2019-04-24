\ A Finite State Machine  Dr. Julian Nobel  (R.I.P)

: PERFORM    POSTPONE @   POSTPONE EXECUTE  ; IMMEDIATE 

: CASE:      CREATE   ;

: |     '  ,  ;                                  \ F83 and ANS version

: ;CASE      DOES>  OVER + +  PERFORM  ;         \ no error checking

: WIDE   0 ;

: FSM:   ( width 0 -- )      CREATE   ,  ,   ;

: ;FSM   DOES>                 ( col# adr -- )

          DUP >R  2@  *  +     ( -- col#+width*state )

          2*  2+  CELLS        ( -- offset-to-action)

          DUP >R               ( -- offset-to-action)
          PERFORM              ( ? )
          R> CELL+             ( -- ? offset-to-update)
          PERFORM              ( -- ? state')

          R> !   ;  ( ? )      \ update state