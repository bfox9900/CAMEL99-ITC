\ Repeating key based on Nouspikel TI-99 tech pages, V1.7 BFox
\ Improved Jan 18, 2021

DECIMAL
 68 CONSTANT LD
  4 CONSTANT SD
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE RPT
\ CREATE DLY LD ,     \ delay var MUST be initiaized to LONG
HEX
: RKEY?   ( -- char)
    RPT @
    IF   SD
    ELSE LD
    THEN ( dly) 0
    DO
       FF 83C8 C!
       KEY?
       OLDKEY @ OVER <>   \ different key?
       IF DUP OUTKEY !
          DUP OLDKEY !
          RPT OFF
          UNLOOP EXIT     \ jump out
       THEN
       DROP
    LOOP
    RPT ON
    OUTKEY @  DUP OLDKEY !
;

: RKEY ( -- char)
   VPOS VC@ >R
   BEGIN
     TMR@ 1FFF > IF CURS @ ELSE R@  THEN VPUT
     PAUSE
     RKEY?
     ?DUP
     CURS @ VPUT
   UNTIL
   R> VPUT
;

\ : TEST BEGIN  RKEY DUP EMIT  83 = UNTIL ;
