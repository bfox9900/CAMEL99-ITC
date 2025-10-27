\ JOYST.FTH  from http://www.unige.ch/medecine/nouspikel/ti99/joystick.htm
\ Tested on REAL TI-99, CAMEL99 TTY Jan 8 2020

\ HEX Outputs in TOS register
\ 01 = Fire
\ 02 = Left
\ 04 = Right
\ 08 = Down
\ 10 = Up
\ 0A = down+left
\ 0C = down+right
\ 12 = up+left
\ 14 = up+right

\ Here is the JOYST program written in Forth with two simple code words
DECIMAL

24 USER 'R12  \ returns memory address of Register 12

HEX
CODE 3CRU!  ( CRU -- )  ( TOS 3 LDCR,) 30C4 ,  NEXT, ENDCODE
CODE 8CRU@  ( -- data)  ( TOS 8 STCR,) 3604 ,  NEXT, ENDCODE

HEX
: JOYST ( joyst# -- n)
        6 +  ><      \
        24 'R12 !
        3CRU!
        6 'R12 !
        8CRU@  >< INVERT 1F AND
        0 83D6 C!
;


: TESTJOYST  BEGIN  0 JOYST  .   ?TERMINAL UNTIL ;
