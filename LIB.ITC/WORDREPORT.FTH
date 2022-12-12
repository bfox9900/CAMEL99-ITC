\ System word Reports

.( .)
\ word type tester
: CODE? ( cfa -- ?) DUP @ 2- = ;
: VAR?  ( cfa -- ?) @ ['] DOVAR = ;
: CON?  ( cfa -- ?) @ ['] DOCON = ;
: USE?  ( cfa -- ?) @ ['] DOUSER = ;
( Special: DOCOL code is in scratchpad RAM)
: COL?  ( cfa -  ?) @  [ ' DOCOL @ ] LITERAL  = ;

: .DECIMAL  BASE @ >R  DECIMAL .  R> BASE ! ;

: TYPE-WORDS ( xt -- n )
  CR
  >R
  0  ( accumulator )
  CONTEXT @ @
  BEGIN
    DUP  ( nfa)
    DUP NFA>CFA  R@ EXECUTE
    IF COUNT TYPE  SPACE
       SWAP 1+ SWAP
    ELSE DROP
    THEN
    NFA>LFA @ DUP
  0= UNTIL
  R> 2DROP ;

: VARIABLES ( -- )  ['] VAR? TYPE-WORDS CR .DECIMAL ." Variables" ;
: USERS     ( -- )  ['] USE? TYPE-WORDS CR .DECIMAL ." USER variables" ;
: CONSTANTS ( -- )  ['] CON? TYPE-WORDS CR .DECIMAL ." Constants" ;
: CODES     ( -- )  ['] CODE? TYPE-WORDS CR .DECIMAL ." CODE words" ;
: COLONS    ( -- )  ['] COL? TYPE-WORDS  CR .DECIMAL ." Colon definitions" ;
