\ DEFER with Forth 2012 extensions Feb 2020 uses PERFORM  BFox
\ taken from  http://forth-standard.org/standard/core/IS
\ *SEE DEFER99 for ALTERNATE version
HERE
: DEFER!  ( xt2 xt1 -- ) >BODY ! ;
: DEFER@  ( 'deferred -- xt) >BODY @ ;

: IS      ( xt "<spaces>name" -- )
         STATE @
         IF    POSTPONE ['] POSTPONE DEFER!
         ELSE  ' ( -- XT) DEFER!
         THEN ; IMMEDIATE

\ CAMEL99 ABORTs if defered word is not defined using 'IS'
: ?DEFER  ( -- ) TRUE ABORT" Undefined DEFER"  ;

: DEFER   ( -- <text>)
          CREATE ['] ?DEFER COMPILE,  ( ?defer is the default action)
          DOES> PERFORM ;

\ Forth 2012 addition this can be commented out if not needed
: ACTION-OF  ( <text> -- xt) ( returns execution token of <text>)
           STATE @
           IF     POSTPONE [']  POSTPONE DEFER@
           ELSE   ' ( -- XT) DEFER@  ( DEFER@ )
           THEN ; IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes )
HEX
