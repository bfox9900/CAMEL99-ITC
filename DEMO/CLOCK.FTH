\ A simple Clock

\ This clock creates a timer based on the TI-99 Interrupt counter
HEX

VARIABLE HRS
VARIABLE MINS
VARIABLE SECS
VARIABLE TICKS

8379 CONSTANT TICKER
\ wait until ticker changes. subtract old value from new value
: 1/60  ( -- )
        TICKER DUP @   \ dup ticker & fetch initial timer value
        BEGIN
             OVER @   \ read it again
             OVER -   \ subtract initial value
        UNTIL         \ loop until result is not zero
        2DROP ;        \ drop the initial value

\ increment no. in the address
: 1+!   ( addr -- ) 1 SWAP +! ;

DECIMAL
: 1SEC   ( -- )  60 0 DO 1/60 LOOP ;

: KEEPTIME
         1SEC SECS 1+!
         SECS @ 60 = IF SECS OFF  MINS 1+! THEN
         MINS @ 60 = IF MINS OFF  HRS  1+! THEN ;

: ##  ( n -- )  0 <# # # #> TYPE ;
: :## ( n -- )  0 <# # # 58 HOLD #> TYPE ;

: .TIME ( -- )  SECS @ MINS @ HRS @  ## :## :## ;

: SETCLOCK  ( hrs mins sec -- )  SECS !  MINS !  HRS ! ;

: CLOCK  ( -- )
         BEGIN
            0 0 AT-XY .TIME
            KEEPTIME
            ?TERMINAL
         UNTIL
         2DROP ;

3 34 0 SETCLOCK

PAGE  20 0 CLOCK
