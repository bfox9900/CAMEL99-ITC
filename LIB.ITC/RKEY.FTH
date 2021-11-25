\ Repeating key based on Nouspikel TI-99 tech pages, V1.7 BFox
\ Improved Oct 21, 2021

DECIMAL
 500 CONSTANT LD
  20 CONSTANT SD

\ VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE RPT

HEX

: WAITKEYUP  ( char delay -- char)
      0 DO
           KEY? OVER <>
           IF
              DUP OLDKEY !
             LEAVE
           THEN
      LOOP ;


: RKEY?   ( -- char)
    FFFF 83C8 !         \ set KEY buffer to empty
    KEY?
    OLDKEY @ OVER <>   \ different key?
    IF   DUP OLDKEY !
         LD
    ELSE SD
    THEN WAITKEYUP 
;

: RSKEY  BEGIN  RKEY?  ?DUP UNTIL ;
: TEST   BEGIN  RSKEY EMIT  ?TERMINAL UNTIL ;


: RKEY ( -- char)
   VPOS VC@ >R
   BEGIN
     RKEY? ?DUP 0=
   WHILE
      PAUSE
      TMR@ 1FFF >
      IF CURS @ VPUT
      ELSE R@ VPUT
      THEN
   REPEAT
   R> VPUT
;

: TEST  BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
