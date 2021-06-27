\ MARKER v2 for CAMEL99 v2.67  record 4 pointers 2021

\ Use:  MARKER REMOVER
\       < ... make new words ... >
\  later...  REMOVER will take the dictionary back to where marker was defined

: MARKER  ( -- )
   LATEST @  HERE           \ get latest word NFA and dictionary position
   CREATE  ( here) , ( nfa)  ,      \ save here & latest
   DOES> DUP 2@             \ runtime: 2-fetch the old values
         DP !
         DUP LATEST !       \ reset system vars
         LATEST DUP CONTEXT ! CURRENT !  \ FORTH DEFINITIONS
;

\ lock the current dictionary for COLD boots
: LOCK    DP @ ORGDP !
          LATEST @ ORGLAST !
;
