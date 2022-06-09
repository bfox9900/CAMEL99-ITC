\ General purpose

: CODE-ALIAS ( XT -- <newname> ) 2+ HEADER  , ; \ FAST but for code words only
: ALIAS  ( XT -- ) >R : R> COMPILE, POSTPONE ; ;
: SYNONYM  ( oldword newword )  '   ALIAS ;
\ ** You must use IMMEDIATE if OLDWORD is IMMEDIATE and you need NEWORD to
\ be immediate
