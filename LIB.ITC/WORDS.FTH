\ words.fth

HEX
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;
: .ID     ( NFAaddr --) COUNT 1F AND TYPE ;
.( ..)
: WORDS   ( -- )
           CR
           0 >R        ( word counter on rstack)
           CONTEXT @ @
           BEGIN DUP
           WHILE
              ?BREAK SPACEBAR
              DUP .ID SPACE
              R> 1+ >R
              NFA>LFA @
           REPEAT
           DROP
           CR R>
           BASE @ >R
           DECIMAL . SPACE ." words"
           R> BASE ! ;
