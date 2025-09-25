\ DEFER with Forth 2012 extensions Feb 2020 uses PERFORM  BFox
\ taken from  http://forth-standard.org/standard/core/IS
\ *SEE DEFER99 for FASTEST version
HERE
: DEFER!  ( xt2 xt1 -- ) >BODY ! ;

: IS      ( xt "<spaces>name" -- )
         STATE @
         IF    POSTPONE ['] POSTPONE DEFER!
         ELSE  ' ( -- XT) DEFER!
         THEN ; IMMEDIATE

\ CAMEL99 ABORTs if deferred word is not defined using 'IS'
: ?DEFER  ( -- ) TRUE ABORT" Undefined DEFER"  ;

: DEFER   ( -- <text>)
          CREATE ['] ?DEFER COMPILE,  ( ?defer is the default action)
          DOES> PERFORM ;

\ Forth 2012 addition this commented out. Seldom needed
\ : DEFER@  ( 'deferred -- xt) >BODY @ ;
\ : ACTION-OF  ( <text> -- xt) ( returns execution token of <text>)
\           STATE @
\           IF     POSTPONE [']  POSTPONE DEFER@
\           ELSE   ' ( -- XT) DEFER@ 
\           THEN ; IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes )
HEX
