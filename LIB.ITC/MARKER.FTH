CR .( MARKER v2.1 for CAMEL99 2.68 2022)
\ Use:  MARKER REMOVER
\       < ... make new words ... >
\  later...  REMOVER will take the dictionary back to where marker was defined

: RELINK ( context dp -- ) DP ! DUP LATEST ! CONTEXT @ ! ;

: MARKER  ( -- )
   CONTEXT @ @  HERE ( -- latest here)
   CREATE  ( here) , ( nfa)  , \ save here & latest
   DOES> 2@ RELINK ;

\ lock the current dictionary for COLD boots
: LOCK    DP @ ORGDP !
          CONTEXT @ @  ORGLAST !
;
