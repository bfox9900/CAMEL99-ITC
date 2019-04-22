\ screen thing

NEEDS GRAPHICS  FROM DSK1.GRAFIX

DECIMAL
CHAR * CONSTANT '*'
CHAR ! CONSTANT '!'
C/SCR @ 1- CONSTANT N  \ chars per screen - 1

: THING
       GRAPHICS
       BEGIN
            2 SCREEN
            '*' SET# 13 1 COLOR
            '!' SET# 7  1 COLOR
            N  0
            DO
               '!'     I   VC!  \ write directly to top of screen
               '*'  N  I - VC!  \ write to bottom of screen
               ( n -- ) 1-
               ?TERMINAL IF GRAPHICS ABORT THEN
               25 MS
            LOOP
            DROP
       AGAIN
;

CLEAR  .( **Type THING to start the demo )
CR     .( FNCT 4 to stop the program)
