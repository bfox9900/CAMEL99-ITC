\ MARKER v2 for CAMEL99 v2.68     AUG 6 2021  Fox
\ Use:  MARKER REMOVER
\       < ... make new words ... >
\  later...
\  REMOVER will take the dictionary back to where marker was defined
VARIABLE CURRSAVE
VARIABLE CNTXSAVE
VARIABLE OLDWID
: MARKER  ( -- )
   CREATE
         HERE , LATEST @ ,  CONTEXT @ , WID-LINK @ ,
   DOES> DUP        2@   DP ! LATEST !
         2 CELLS +  2@   CONTEXT !  WID-LINK !
;

\ lock the current dictionary for COLD boots
: LOCK    DP @        ORGDP !
          LATEST  @ ORGLAST !
          CURRENT @ CURRSAVE !
          WID-LINK @ OLDWID !
;
