\ Repeating key based on Nouspikel TI-99 tech pages heavily modified  Brian Fox
\ Apr 2002 Experimental verison with inverted char cursor

\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.BUFFER

HERE
DECIMAL
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
CREATE RPT  10 ,    \ initial delay
VARIABLE SCHAR      \ screen character
VARIABLE INVERTED

8 BUFFER: PAT-BUFFER

HEX
: ]PDT   ( char -- Vaddr) 8* 800 + ; \ pattern descriptor array

: INVERT-CHAR ( char --)
      ]PDT 8 BOUNDS ( -- Vaddr-end Vaddr-start )
      DO
         I V@ INVERT I V!  \ read 16bit VDP data, invert, store back to VDP
      2 +LOOP
;

: BLINK  ( char -- )
      TMR@ 1FFF >                         \ test 9901 timer
      IF
         ]PDT PAT-BUFFER 8 VREAD          \ char pattern -> RAM buffer
         PAT-BUFFER  CURS @ ]PDT 8 VWRITE \ copy buffer cursor pattern
         CURS @ DUP INVERT-CHAR           \ invert cursor pattern
      THEN VPUT ;                         \ put char on the screen

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
    OUTKEY @  DUP OLDKEY !
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
HEX
: TEST
    001B CURS !  \ unused character for the cursor
    BEGIN
      ?TERMINAL 0=
    WHILE
       RKEY EMIT
    REPEAT
    5F CURS ! ;  \ Restore underline cursor
