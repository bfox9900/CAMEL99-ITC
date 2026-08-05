\ SPLITJOIN.FTH   for POCO editor


: SPLITLN ( addr n )
    PAD PLACE
    PAD COUNT LEFTSIDE  THELINE# ]$OVERWRITE
    RELOAD-BUFFER RETYPE.BUFFER

    (DOWN)
    PAD COUNT RIGHTSIDE INSERTLN
    HOME
    RELOAD-BUFFER
;

: SPLITEST   $EDIT-BUFFER  SPLITLN  ;

: LEFT$  ( addr n n2 -- ) NIP ;

: JOINLINES
    THELINE#  #LINES @ = IF  BEEP EXIT RETURN;
    ?WRITE-BACK
    THELINE# 1+ ]POOL$
    EDIT-BUFFER LEN
\ get size we can fit in editor buffer or entire line below
     80 OVER -  MIN  DUP>R  \ remember how many we are taking
( addr len n) LEFT$ EDIT-BUFFER +PLACE  \ add 2nd line bytes to edit-buffer
    THELINE# WRITE-BACK

\ now cut the pool$ by the amount we joined to the above line
    THELINE# 1+ ]POOL$  R> /STRING  -TRAILING
    DUP 0= IF  2DROP  THELINE# 1+ DELETELINE  RETURN;

\ We know the new string is smaller so it will fit in the same pool$
    THELINE# 1+ ]NODE @ VIRT>REAL PLACE

    UPDATE   \ mark disk buffer for flushing
   \ REDRAW
;
