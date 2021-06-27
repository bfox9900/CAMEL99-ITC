\ system report

INCLUDE DSK1.TOOLS
.( ..)
: VARIABLES ( -- )
           CR
           0 >R        ( word counter on stack)
           CONTEXT @ @
           BEGIN
             SPACEBAR
            ?BREAK
             DUP  ( nfa)
             DUP NFA>CFA @ ['] DOVAR =
             IF .ID SPACE
                R> 1+ >R       \ inc. the counter
             ELSE DROP
             THEN
             NFA>LFA @ DUP
           0= UNTIL
           DROP
           CR R> BASE @ >R DECIMAL . SPACE ." variables"
           R> BASE ! ;


.( ..)
: USERS ( -- )
            CR
            0 >R        ( word counter on stack)
            CONTEXT @ @
            BEGIN
               SPACEBAR
              ?BREAK
               DUP  ( nfa)
               DUP NFA>CFA @ ['] DOUSER 2+ =
               IF .ID SPACE
                   R> 1+ >R       \ inc. the counter
               ELSE DROP
               THEN NFA>LFA @ DUP
            0= UNTIL
            DROP
            CR R> BASE @ >R
            DECIMAL . SPACE ." user variables"
            R> BASE ! ;

: CONSTANTS ( -- )
         CR
         0 >R        ( word counter on stack)
         CONTEXT @ @
         BEGIN
            SPACEBAR
           ?BREAK
            DUP  ( nfa)
            DUP NFA>CFA @ ['] DOCON =
            IF .ID SPACE
               R> 1+ >R       \ inc. the counter
            ELSE DROP
            THEN NFA>LFA @ DUP
         0= UNTIL
         DROP
         CR R> BASE @ >R
         DECIMAL . SPACE ." constants"
         R> BASE ! ;

: CODE? ( cfa -- ?) DUP @ 2- = ;

: CODES ( -- )
        CR
        0 >R        ( word counter on stack)
        CONTEXT @ @
        BEGIN
           SPACEBAR
          ?BREAK
           DUP  ( nfa)
           DUP NFA>CFA CODE?
           IF .ID SPACE
              R> 1+ >R       \ inc. the counter
           ELSE DROP
           THEN NFA>LFA @ DUP
        0= UNTIL
        DROP
        CR R> BASE @ >R
        DECIMAL . SPACE ." CODE words"
        R> BASE ! ;
