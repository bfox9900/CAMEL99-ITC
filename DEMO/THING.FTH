\ screen thing

NEEDS GRAPHICS  FROM DSK1.GRAFIX

DECIMAL
CHAR * CONSTANT '*'
CHAR ! CONSTANT '!'
C/SCR @ 1- CONSTANT N  \ chars per screen - 1

: THING
      GRAPHICS
      2 SCREEN
       BEGIN
           PAGE
          '*' SET# 13 1 COLOR
          '!' SET# 7  1 COLOR
          N 2/ 2/  N
          DO
               '!'     I   VC!  \ write directly to top of screen
               '*'  N  I - VC!  \ write to bottom of screen
               ( n -- ) 1-
               ?TERMINAL ABORT" *break*
               25 MS
          -1 +LOOP
          DROP
       AGAIN
;

CLEAR  .( **Type THING to start the demo )
CR     .( FNCT 4 to stop the program)
