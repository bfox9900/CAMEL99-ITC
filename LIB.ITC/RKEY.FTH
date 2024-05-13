\ Repeating key based on Nouspikel TI-99 tech pages,   V2 BFox
\ Mar 2022  used TICKS to control minimum loop speed.

HERE
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
CREATE RPT  10 ,    \ initial delay
VARIABLE SCHAR      \ screen character

HEX
: BLINK  ( char -- ) TMR@ 1FFF > IF DROP  CURS @  THEN VPOS VC! ;

: RKEY?  ( -- char)
    RPT @ >R    \ delay counter to rstack
    SCHAR @ BLINK
    83C8 OFF
    BEGIN
        R> 1- DUP>R        \ dec counter
    WHILE ( not expired)
        83C8 ON   \ clear key buffers
        KEY? DUP OUTKEY !
        OLDKEY @ =         \ compare to oldkey
    WHILE ( key is same)
        220 TICKS          \ sets the speed of the loop
        9 RPT !  \ set fast repeats
    REPEAT
    80 RPT !     \ set long delay (initial delay)
    THEN         \ end time expired loop
    R> DROP
    OUTKEY @ DUP OLDKEY !
;

: RKEY ( -- char)
   VPOS C@ SCHAR !
   BEGIN
      RKEY? DUP
   0= WHILE
      PAUSE
      DROP
      OUTKEY OFF
   REPEAT
   SCHAR @ VPOS VC!
;

HERE SWAP - DECIMAL SPACE .

: TEST    BEGIN  RKEY EMIT  ?TERMINAL UNTIL ;
