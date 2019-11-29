\ XONXOFF.FTH
HEX
11 CONSTANT ^Q
13 CONSTANT ^S

: XEMIT  ( c -- )   \ * XON/XOFF version*
         KEY? ^S =
         IF  BEGIN
               PAUSE
               KEY? DUP 3 = ABORT" ^C"
               ^Q =
             UNTIL
         THEN CEMIT ;   \ send c to TTY1

: XKEY
         BEGIN
            PAUSE
            CKEY?
            ?DUP



: XON/XOFF   ( -- ) ['] (XEMIT)  'EMIT ! ;
: STD-IO     ( -- ) ['] (EMIT)   'EMIT ! ;

ABORT
