\ blinky: write to screen based on a stack value that is negative or positive
\ and toggle the value after each write.

INCLUDE DSK1.GRAFIX

3 CONSTANT GREEN
7 CONSTANT RED

DECIMAL
: BLINKY   GRAPHICS
           PAGE ." Blinky: Press a key to exit"
            -1
           BEGIN
              12 11 AT-XY
              DUP 0>
              IF   ." *  GO  *"  GREEN SCREEN
              ELSE ." * STOP *"  RED   SCREEN
              THEN NEGATE
              500 MS
              KEY?
           UNTIL ;
