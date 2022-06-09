\ EDITLINE

NEEDS DSK1.CASE

VARIABLE CURTIM   FF CURTIM !

: ECURS@  ( -- c)  \ C= EITHER: char on screen or cursor char
          CURTIM 1-!
          CURTIM @
          0= IF
             FF CURTIM !
             DROP VPOS VC@
          ELSE
             CURS@
          THEN ;

: EDKEY
        BEGIN
          ECURS@ VPUT                  \ show the flashing cursor
          PAUSE                        \ multi-tasking switch
          KEY?
          ?DUP
        UNTIL                          \ wait for key press
        VPOS VC@ VPUT ;                \ restore character under cursor


: EDITLINE ( addr len pos -- addr len)
           OVER + 1- OVER
           BEGIN
              EDKEY DUP 0D <>
           WHILE
              DUP EMIT
              CASE
                 8 OF   DROP 1-  >R OVER R> UMAX   ENDOF

                 OVER C!  1+ OVER UMIN

              ENDCASE
           REPEAT
           DROP NIP SWAP -  ;
