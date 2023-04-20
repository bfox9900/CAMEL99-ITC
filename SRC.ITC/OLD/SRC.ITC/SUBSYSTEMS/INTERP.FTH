\ I N T E R P R E T E R

: INTERPRET  ( addr len -- ) 'IV PERFORM ;

\ ======================================================================
\ Q U I T :  The  O U T E R   I N T E R P R E T E R

: QUIT     ( -- )
           L0 LP !   RP0 RP!
           SOURCE-ID OFF
           t[COMPILE] [
           BEGIN
              TIB DUP 80 ACCEPT SPACE    \ TIB is $80 (128) bytes long
            ( addr len) INTERPRET
             STATE @ 0= IF  T."  ok"  THEN CR
           AGAIN ;

: EVALUATE ( c-addr u -- j*x)
           SOURCE-ID ON
           SOURCE 2>R
           >IN @ >R
           INTERPRET
           R> >IN !
           2R> 'SOURCE 2!
           SOURCE-ID OFF ;

\ ======================================================================
\ E R R O R   H A N D L I N G
\
: ABORT    ( -- )
           SP0 SP!
           VDPTOP ^PAB !   \ set base pab pointer
           CR QUIT ;

: ?ABORT   ( f caddr u --)
           ROT
           IF
             CR
             CR T." * " TYPE  T."  ?" HONK
             SOURCE-ID @   ( if source is NOT console)
             0> IF  T."  Line " LINES @ DECIMAL U.
                 CR CR SOURCE TYPE
             THEN ABORT
           THEN 2DROP ;

                  \ flag        addr length
: ?ERR     ( ? -- )             HERE COUNT ?ABORT ;
: ?EXEC    ( -- ) STATE @       TS" Interpret only" ?ABORT ;
: ?COMP    ( -- ) STATE @ 0=    TS" Compile only"   ?ABORT ;
: ?CSP     ( -- ) SP@ CSP @ -   TS" Unfinished"     ?ABORT ;
: !CSP     ( -- ) SP@ CSP ! ;
