\ joystick reader from TI-Forth  (VERY SLOW)

NEEDS CASE FROM DSK1.CASE

HEX
: JOYST ( keybdno --- ascii xstat ystat )
      8374 C!
      KEY? DROP 8375 C@
      DUP DUP 12 =
      IF DROP 0 0
      ELSE 0FF =
           IF 8377 C@ 8376 C@
           ELSE 8375 C@
             CASE
                 4 OF  0FC  4   ENDOF
                 5 OF   0   4   ENDOF
                 6 OF   4   4   ENDOF
                 2 OF  0FC  0   ENDOF
                 3 OF   4   0   ENDOF
                 0 OF   0  0FC  ENDOF
                0F OF  0FC 0FC  ENDOF
                0E OF   4  0FC  ENDOF

                DROP DROP 0 0 0 0 \ default action

             ENDCASE
            THEN
      THEN
      4 8374 C! ;
