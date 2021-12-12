\ Repeating key based on Nouspikel TI-99 tech pages,   V2 BFox
\ Improved Dec 11, 2021

HERE
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE RPT

HEX
: RKEY?   ( -- char)
    RPT @
    IF    3             \ short delay value
    ELSE 45             \ long delay value
    THEN >R             \ delay counter on rstack
    BEGIN
       R> 1- DUP>R      \ dect. counter
    WHILE ( counter>0)
       83C8 ON          \ clear key buffer
       KEY?             \ call kscan
       OLDKEY @ OVER =  \ compare to oldkey
    WHILE ( key is same)
       DROP             \ don't need this key
       RPT ON
    REPEAT ( endwhile #2)
      DUP OUTKEY !  OLDKEY !
      RPT OFF
    THEN ( endwhile #1)
    R> DROP             \ remove the counter
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

HERE SWAP - DECIMAL .  ( 194 bytes)

\ : TEST  BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
