\ DEFER optimized for TI-99
\ taken from  http://forth-standard.org/standard/core/IS

HERE
: DEFER!  ( xt2 xt1 -- ) >BODY ! ;
: IS      ( xt "<spaces>name" -- )
         STATE @
         IF    POSTPONE [']  DEFER!
         ELSE  ' ( -- XT) DEFER!
         THEN ; IMMEDIATE

\ CAMEL99 ABORTs if deferred word is not defined using 'IS'
: ?DEFER  ( -- ) HERE COUNT CR TYPE TRUE ABORT" Undefined DEFER"  ;

\ fastest running DEFER words
\ HEX
 : DEFER ( xt -- )
              CREATE  ['] ?DEFER ,  ( ?defer is the default action)
              ;CODE  C218 , \ *W  W  MOV,  \ fetch address in W->W
                     C178 , \ *W+ R5 MOV,  \ move contents of the XT ++
                     0455 , \  R5 ** B,    \ branch to the address
              ENDCODE

\ Forth 2012 addition this commented out. Seldom needed
\ : DEFER@  ( 'deferred -- xt) >BODY @ ;
\ : ACTION-OF  ( <text> -- xt) ( returns execution token of <text>)
\           STATE @
\           IF     POSTPONE [']  POSTPONE DEFER POSTPONE @
\           ELSE   ' ( -- XT) >BODY @
\           THEN ; IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes )
HEX
