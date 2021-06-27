\ XONXOFF.FTH
HEX
11 CONSTANT ^Q
13 CONSTANT ^S

: WAIT^Q ( -- )
          BEGIN
             PAUSE
             CKEY? ^Q =
          UNTIL
;

\ * XON/XOFF version*
: XEMIT  ( c -- ) CKEY? ^S = IF   WAIT^Q  THEN CEMIT ;
: XON/XOFF   ( -- ) ['] XEMIT  'EMIT ! ;
: STD-OUT    ( -- ) ['] CEMIT  'EMIT ! ;


