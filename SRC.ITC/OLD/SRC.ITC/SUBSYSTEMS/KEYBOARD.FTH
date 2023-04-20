\ KEYBOARD INPUT 
\ *G Cursor flash control is now done by reading the 9901 timer.
\ ** It counts down from >3FFF in 349mS. If the timer> 1FFF we show the cursor.
\ ** If < 1FFF show the screen char. Flash rate is about 2 per second.

TARGET-COMPILING
: KEY      ( -- char)
           BEGIN                  \ start the loop
              PAUSE               \ Essential for Multi-tasking with Console
              CURS @              \ fetch 2 char cursor (space & _ )
              TMR@ 1FFF <         \ compare hardware timer to 1FFF
              IF >< THEN VPUT     \ swap cursor bytes & write
              KEY?                \ check the keyboard
              ?DUP                \ DUP IF <> 0
            UNTIL                 \ loop until a key pressed
            BL VPUT ;             \ put the space char on screen

\ High level: input/output          (c) 31mar95 bjr
: ACCEPT     ( caddr +n -- +n')
             OVER + OVER         \ removed 1-  to accept all chars
             BEGIN
                KEY DUP 0D <>
             WHILE
                DUP EMIT
                DUP 8 =
                IF   DROP 1-  3 PICK  UMAX  \ changed to use: 3 PICK   B.F.
                ELSE OVER C!  1+ OVER UMIN
                THEN
             REPEAT
             DROP NIP SWAP -  ;
