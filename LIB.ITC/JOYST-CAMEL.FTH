\ JOYST.FTH  from http://www.unige.ch/medecine/nouspikel/ti99/joystick.htm
\ Tested on REAL TI-99, CAMEL99 TTY Jan 8 2020

\ HEX Output in TOS register ( mask bit 0 for fire detection )
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
CODE CRUC@  ( -- data)  ( TOS 8 STCR,) 3604 ,  NEXT, ENDCODE

HEX
: JOYST ( joyst# -- n) \ compare to Assembler version
        6 +         \ TOS  06 AI,     \ joyst# to real CRU adress
        ><          \ TOS     SWPB,
        24 'R12 !   \ R12  24 LI,     \ joystick i/o address
        3CRU!       \ TOS  03 LDCR,   \ write 3 bits to enable joystick#
        6 'R12 !    \ R12  06 LI,     \ select column 6
        CRUC@       \ TOS  08 STCR,   \ read 8 bits
        ><          \ TOS     SWPB,   \ swap byte
        INVERT      \ TOS     INV,    \ change to positive logic
        1F AND      \ TOS 01F ANDI,   \ mask off the junk
        83D6 OFF    \ 83D6 @@ CLR,    \ reset screen timeout
;

: TESTJOYST
        BEGIN
          0 JOYST
          DUP 0001 AND
          IF   DROP ." >>FIRE!<<"
          ELSE .
          THEN
          ?TERMINAL
        UNTIL ;
