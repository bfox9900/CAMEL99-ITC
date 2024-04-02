\ XONXOFF.FTH
HEX
11 CONSTANT ^Q
13 CONSTANT ^S
03 CONSTANT ^C

: KEY?    ( -- c)  KEY? 7F AND ;  \ 7 bit ascii output
: WAITKEY ( char -- )
  BEGIN PAUSE  KEY? DUP ^C = ABORT" ^C"    OVER = UNTIL DROP ;

: XEMIT   ( c -- ) KEY? ^Q = IF ^S WAITKEY  THEN EMIT ;
: XTYPE   ( addr len --) 0 DO  COUNT XEMIT  LOOP DROP ;

\ over-write the kernel ."  with this
: ."
    POSTPONE S"
    STATE @ IF  POSTPONE XTYPE   EXIT THEN   XTYPE  ; IMMEDIATE

: TEST
   BEGIN
     CR ." This text can be stopped by using ^Q"
     CR ." You can restart it by pressing ^S"
     CR ." While the text is stopped, press ^C to break"
     CR
     ?TERMINAL ABORT" BREAK"
   AGAIN ;
