CR .( ANS/ISO Loop & Branch)

: AHEAD ( -- addr) HERE   0 , ;
: <BACK ( addr --) HERE -  , ;

: THEN   ( addr -- ) HERE OVER - SWAP ! ;     IMMEDIATE
: BEGIN   HERE ;                              IMMEDIATE
: IF      POSTPONE ?BRANCH AHEAD ;            IMMEDIATE
: ELSE    POSTPONE BRANCH  AHEAD SWAP POSTPONE THEN ; IMMEDIATE
: UNTIL   POSTPONE ?BRANCH <BACK ;  IMMEDIATE
: AGAIN   POSTPONE BRANCH  <BACK ;  IMMEDIATE
: WHILE   POSTPONE IF SWAP ;        IMMEDIATE
: REPEAT  POSTPONE AGAIN POSTPONE THEN ; IMMEDIATE

\ CAMEL Forth LEAVE stack pointer is initialized by QUIT
: >L       ( x -- ) ( L: -- x )  2 LP +!  LP @ ! ;
: L>       ( -- x )  ( L: x -- ) LP @ @   -2 LP +! ;

\                      -compile this-  - run this now-
: DO      ( -- ) ?COMP POSTPONE <DO>     HERE 0 >L ;  IMMEDIATE
: ?DO     ( -- ) ?COMP POSTPONE <?DO>    HERE 0 >L ;  IMMEDIATE
: LEAVE   ( -- ) ( L: -- addr )
          POSTPONE UNLOOP   POSTPONE BRANCH AHEAD >L ; IMMEDIATE

: RAKE   ( -- ) ( L: 0 a1 a2 .. aN -- )
   BEGIN  L> ?DUP       \ read leave stack, dup if <>0
   WHILE  POSTPONE THEN \ resolve branch in LEAVE
   REPEAT
   L0 LP ! ; IMMEDIATE  \ reset the leave stack


: LOOP    ( -- )  COMPILE <LOOP>   <BACK RAKE ; IMMEDIATE
: +LOOP   ( -- )  COMPILE <+LOOP>  <BACK RAKE ; IMMEDIATE
