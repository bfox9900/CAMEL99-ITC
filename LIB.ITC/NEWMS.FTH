
DECIMAL 59 CONSTANT K  \ 59 creates a 2mS delay

: MS    ( n -- )
        2/ 0
         ?DO
            TMR@
            BEGIN
               TMR@ |-| K >
            UNTIL
            DROP
          LOOP ;
