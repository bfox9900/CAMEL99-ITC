\ Repeating key based on Nouspikel TI-99 tech pages, V1.8 BFox

\ NEEDS .S FROM DSK1.TOOLS

DECIMAL
 75 CONSTANT LD
  5 CONSTANT SD
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE CNTR
LD CREATE DLY  ,     \ delay var MUST be initiaized to LONG

HEX
:  RKEY? ( screen_char -- char)
\    DLY @ SD <>  IF  LD DLY !  THEN
    DLY @ CNTR !        \ select the delay
    BEGIN
      CNTR DUP 1-! @
    WHILE
      OUTKEY @ OLDKEY @ = IF 00 83C8 C! THEN
      KEY?               \ Call ROM KSCAN
      DUP OUTKEY !
      OLDKEY @ OVER <>   \ different key?
      IF
           DUP OLDKEY !  \ memorize and return the key
           LD DLY !      \ reload waiting delay
           EXIT          \ jump out
      ELSE
          DROP
      THEN
   REPEAT                \ while true, repeat
   SD DLY !              \ load repeat delay
   OUTKEY @              \ return key
;

: RKEY ( -- char)
    KEY? DROP
    VPOS VC@ >R
    BEGIN
      TMR@ 1FFF >
      IF CURS @ ELSE R@ THEN VPUT
      PAUSE
      RKEY?
      ?DUP
    UNTIL
    R> VPUT
;

: TEST   BEGIN  RKEY EMIT  ?TERMINAL   UNTIL ;
