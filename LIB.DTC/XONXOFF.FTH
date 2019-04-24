\ XONXOFF.FTH
HEX
11 CONSTANT ^Q
13 CONSTANT ^S

: (XEMIT)  ( c -- )   \ * XON/XOFF version*
KEY? ^S = IF  BEGIN  PAUSE  KEY? DUP 3 = ABORT" ^C"  ^Q = UNTIL THEN
CEMIT ;   \ send c to TTY1 

: XON/XOFF   ( -- ) ['] (XEMIT)  'EMIT ! ;
: NOHANDSHK  ( -- ) ['] (EMIT)   'EMIT ! ;

ABORT
