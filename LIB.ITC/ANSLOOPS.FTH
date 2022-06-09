\ ========================================================================
\ ANS Forth loops allow multiple WHILE statements in a loop.
\ This is proven to be very handy for some algorithms  
\ ### NO COMPILE TIME MATCHING ###
\ ========================================================================
\ C O N D I T I O N A L   B R A N C H E S
: RESOLVE  ( addr -- ) HERE OVER - SWAP ! ;

: IF          ( ? -- ) ?COMP POSTPONE ?BRANCH AHEAD ;  IMMEDIATE
: THEN        ( -- )   ?COMP RESOLVE ;                 IMMEDIATE
: ELSE        ( -- )   POSTPONE BRANCH AHEAD SWAP
                       POSTPONE THEN ;                 IMMEDIATE

\ ========================================================================
\ I N F I N I T E   L O O P   C O M P I L E R S
: BEGIN       ( -- addr n) ?COMP HERE ;         IMMEDIATE
: AGAIN       ( -- )   POSTPONE  BRANCH BACK ;  IMMEDIATE
: UNTIL       ( ? -- ) POSTPONE ?BRANCH BACK ;  IMMEDIATE
: WHILE       ( ? -- ) POSTPONE IF >BODY ;      IMMEDIATE
: REPEAT      ( -- )
              2>R    POSTPONE AGAIN
              2R> 2- POSTPONE THEN ; IMMEDIATE
