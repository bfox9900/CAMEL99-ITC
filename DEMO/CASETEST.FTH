\ CASE TESTER

INCLUDE DSK1.CASE
INCLUDE DSK1.FASTCASE
INCLUDE DSK1.ELAPSE


: FOO      ." Foo " ;
: BAR      ( ." Bar ")  ;

DECIMAL
: FOO1    ( FOO 1 . ) ;
: FOO2    ( FOO 2 . )  ;
: FOO3    ( FOO 3 . ) ;
: FOO4    ( FOO 4 . ) ;
: FOO5    ( FOO 5 . ) ;
: FOO6    ( FOO 6 . ) ;
: FOO7    ( FOO 7 . ) ;
: FOO8    ( FOO 8 . ) ;
: FOO9    ( FOO 9 . ) ;
: FOO10   ( FOO 10 . )  ;


: EAKER  ( n -- )
         CASE
            0 OF ( BAR) ENDOF
            1 OF FOO1  ENDOF
            2 OF FOO2  ENDOF
            3 OF FOO3  ENDOF
            4 OF FOO4  ENDOF
            5 OF FOO5  ENDOF
            6 OF FOO6  ENDOF
            7 OF FOO7  ENDOF
            8 OF FOO8  ENDOF
            9 OF FOO9  ENDOF
           10 OF FOO10 ENDOF
        ENDCASE ;

\ creates a vector table
CASE: KALIHAN ( n -- )
            | BAR          \ 0 case
            | FOO1
            | FOO2
            | FOO3
            | FOO4
            | FOO5
            | FOO6
            | FOO7
            | FOO8
            | FOO9
            | FOO10
;CASE

\ v2.0 15 SEC
\ v2.8 13.36sec  by using OVER= optimizer
:  TEST1   CR ." Eaker 1000x"    1000 0  DO  11 0 DO I EAKER   LOOP   LOOP ;

:  TEST2   CR ." Kalihan 1000x"  1000 0  DO  11 0 DO I KALIHAN LOOP   LOOP ;  \  5.3 SEC

\ v2.0 7.26 SEC
\ v2.8 5.71 sec with OVER= optimizer
:  TEST3   CR ." Eaker 10, 3000x"    3000 0  DO  10 EAKER    LOOP ;

\ v2 1.66 SEC 4x faster
\ v2.8  1.35 seconds, probably due to EXECUTOR improvement
:  TEST4   CR ." Kalihan 10, 3000x"  3000 0  DO  10 KALIHAN  LOOP ;
