\ ==================================================================
\ *** debugging ***

\ print line buffers to the display screen
: SHOW-BUFFERS ( line# -- )
    L/SCR 0 DO
        I OVER + ]LINE$  CR TYPE
        ?TERMINAL ABORT" *BREAK*"
        SPACEBAR
    LOOP ;


\ *** demo ***
INCLUDE DSK1.CASE
INCLUDE DSK1.RKEY

VARIABLE TOPLINE

: CLIP  ROT MIN MAX ;
: TOPLINE+! ( n -- ) TOPLINE @ +  0 #LINES @ 1- CLIP  TOPLINE ! ;

: DEMO
    TOPLINE OFF
    BEGIN
        TOPLINE @ REDRAW
        RKEY
        CASE
          11 OF  -1 TOPLINE+!  ENDOF
          10 OF   1 TOPLINE+!  ENDOF
           2 OF  PAGE ." Forth" ABORT ENDOF
        ENDCASE
    AGAIN
;
