\ DEFER with Forth 2012 extensions
\ taken from  http://forth-standard.org/standard/core/IS

: DEFER!  ( xt2 xt1 -- )  >BODY ! ;

: DEFER@  ( 'deferred -- xt)  >BODY @ ;

: IS      ( xt "<spaces>name" -- )
          STATE @
           IF    POSTPONE ['] POSTPONE DEFER!
           ELSE  ' ( -- XT) DEFER!
          THEN ; IMMEDIATE

\ CAMEL99 ABORTs if defered word is not defined using 'IS'
: ?DEFER  ( -- ) TRUE ABORT" Undefined DEFER"  ;

\ : DEFER   ( -- <text>)
\          CREATE ['] ?DEFER ,  ( ?defer is the default action)
\          DOES> @ EXECUTE ;

\ much faster version
 : DEFER ( xt -- )
              CREATE  ['] ?DEFER ,  ( ?defer is the default action)
              ;CODE  C218 , \ *W  W  MOV,  \ fetch address in W->W
                     C178 , \ *W+ R5 MOV,  \ move contents of the XT
                     0455 , \ R5 **  B,    \ branch to the address
              ENDCODE


\ Forth 2012 addition this can be commented out if not needed
: ACTION-OF  ( <text> -- xt) ( returns execution token of <text>)
           STATE @
           IF     POSTPONE [']  POSTPONE DEFER@
           ELSE   ' ( -- XT) DEFER@  ( DEFER@ )
           THEN ; IMMEDIATE
