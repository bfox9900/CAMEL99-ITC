CR .( Compiler branching and looping )
\ ** MUST be loaded when the KERNEL boots to complete the system

\ branch calculators/compilers help me understand this code better
: AHEAD    ( -- addr)  HERE   0 , ;
: BACK     ( addr -- ) HERE   - , ;
: RESOLVE  ( addr -- ) HERE OVER - SWAP ! ;
.( .)
\ CAMEL Forth LEAVE stack is called L0. It is initialized by QUIT.
: >L        ( x -- ) ( L: -- x )  2 LP +!  LP @ ! ;
: L>        ( -- x )  ( L: x -- ) LP @ @   -2 LP +! ;


CR .( branching)
: IF      ( ? -- ) ?COMP POSTPONE ?BRANCH AHEAD 2 ;   IMMEDIATE
: THEN    ( -- )   ?COMP  2 ?PAIRS RESOLVE ;          IMMEDIATE
: ELSE    ( -- )   ?COMP  2 ?PAIRS  POSTPONE BRANCH AHEAD 
                   SWAP 2 POSTPONE THEN 2 ; IMMEDIATE
.( .)

CR .( infinite loop compilers)
: BEGIN   ( -- addr n) ?COMP HERE  1  ;              IMMEDIATE
: AGAIN   ( -- )   1 ?PAIRS POSTPONE BRANCH BACK   ;  IMMEDIATE
: UNTIL   ( ? -- ) 1 ?PAIRS POSTPONE ?BRANCH BACK  ;  IMMEDIATE
: WHILE   ( ? -- ) POSTPONE IF  2+  ;                IMMEDIATE
: REPEAT  ( -- )   2>R  POSTPONE AGAIN  2R> 2- POSTPONE THEN ; IMMEDIATE
.( .)

CR .( finite loop compilers)
: RAKE      ( -- ) ( L: 0 a1 a2 .. aN -- )
            BEGIN  L> ?DUP WHILE  RESOLVE  REPEAT ;   IMMEDIATE
.( .)
: DO        ( -- ) POSTPONE <DO>     HERE 0 >L   3 ;  IMMEDIATE
: ?DO       ( -- ) POSTPONE <?DO>    HERE 0 >L   3 ;  IMMEDIATE
: LEAVE     ( -- ) ( L: -- addr )
            POSTPONE UNLOOP   POSTPONE BRANCH AHEAD >L ; IMMEDIATE
: LOOP      ( -- )
            3 ?PAIRS POSTPONE  <LOOP>  BACK POSTPONE RAKE ; IMMEDIATE
: +LOOP     ( -- )
            3 ?PAIRS POSTPONE <+LOOP> BACK   POSTPONE RAKE ; IMMEDIATE



