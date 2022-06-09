\ Repeating key based on Nouspikel TI-99 tech pages, V1.7 BFox
\ Improved Oct 21, 2021

DECIMAL
 60 CONSTANT LD
  4 CONSTANT SD

VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE RPT

HEX
: RKEY?   ( -- char)
    RPT @
    IF   SD
    ELSE LD
    THEN
    0 DO
       83C8 ON
       KEY?
       OLDKEY @ OVER <>   \ different key?
       IF DUP OUTKEY !
          DUP OLDKEY !
          RPT OFF
          LEAVE     \ jump out
       THEN
       DROP
       RPT ON
    LOOP
    OUTKEY @
;

: RKEY ( -- char)
   VPOS VC@ >R
   BEGIN
     PAUSE
     TMR@ 1FFF >
     IF CURS @ ELSE R@  THEN VPUT
     RKEY?
     ?DUP
   UNTIL
   R> VPUT
;

: TEST  BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
