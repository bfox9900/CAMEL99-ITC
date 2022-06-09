\ Repeating key based on Nouspikel TI-99 tech pages,   V2 BFox
\ Improved Dec 11, 2021

HERE
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE RPT

: TIMEKEY ( wait-time -- 0 | c )  \ waits for a key until counter hits zero
      BEGIN
         1- DUP
      WHILE
       83C8 ON KEY? 0=
      WHILE
          NIP
      REPEAT
      THEN
      OUTKEY !
;

HEX
: RKEY?   ( -- char)
    RPT @
    IF    3 TIMEKEY    \ short delay value
    ELSE 45 TIMEKEY    \ long delay value
    THEN

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

HERE SWAP - DECIMAL .  ( 194 bytes)

: TEST  BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
