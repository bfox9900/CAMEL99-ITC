\ Repeating key based on Nouspikel TI-99 tech pages,   V2 BFox
\ Mar 2022  used TICKS to control minimum loop speed.

HERE
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
CREATE RPT  10 ,    \ initial delay
VARIABLE SCHAR      \ screen character

HEX
: BLINK  ( char -- ) TMR@ 1FFF > IF DROP  CURS @  THEN VPUT ;

: RKEY?  ( -- char)
    SCHAR @ BLINK
    RPT @ >R    \ delay counter to rstack
    BEGIN
        R> 1- DUP>R        \ dec counter
    WHILE ( not expired)
        83C8 ON  83CA ON   \ clear key buffers
        700 TICKS          \ sets the speed of the loop
        KEY? DUP OUTKEY !
        OLDKEY @ =         \ compare to oldkey
    WHILE ( key is same)
        2 RPT !  \ set fast repeats
    REPEAT
    0A RPT !     \ set long delay (initial delay)
    THEN         \ end time expired loop
    R> DROP
    OUTKEY @
    DUP OLDKEY !
    OUTKEY OFF
;

: RKEY ( -- char)
   VPOS VC@ SCHAR !
   BEGIN
      RKEY? DUP
   0= WHILE
     PAUSE
     DROP
   REPEAT
   SCHAR @ VPUT
;

HERE SWAP - DECIMAL SPACE .

: TEST    BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
