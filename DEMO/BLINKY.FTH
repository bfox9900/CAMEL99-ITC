\ blinky: write to screen based on a stack value that is negative or positive
\ and toggle the value after each write.

INCLUDE DSK1.GRAFIX

DECIMAL
: BLINKY   GRAPHICS
           PAGE ." Blinky: Press a key to exit"
            -1
            BEGIN
              12 11 AT-XY
              DUP 0>
              IF   ." *  GO  *" 3 SCREEN
              ELSE ." * STOP *" 7 SCREEN
              THEN NEGATE
              500 MS
              KEY?
           UNTIL  ;
