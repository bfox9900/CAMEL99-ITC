\ tail call optimizing semicolon for Camel99 Forth  Nov 27 2022 Brian Fox

DECIMAL 
: CELL-   2- ;
: PREVXT ( -- XT)  HERE CELL- @ ; \ fetch the XT of previous compiled word

\ -; does not end with EXIT because it is branching directly to another
\ list of tokens. That other list will end in EXIT or NEXT.
: -;  ( -- ) \ programmer controlled
      PREVXT >BODY              \ get previous XT, compute PFA
     -2 ALLOT                   \ erase the previous XT
      POSTPONE BRANCH HERE - ,  \ compile BRANCH to the PFA
      POSTPONE [                \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE

\ >> smart version but you don't need it << 
\ : COLON?  ( xt -- ?) @  [ ' DOCOL @ ] LITERAL = ;
\VARIABLE TAILCALL  \ control tail call optimizizing with this variable
                   \ TAILCALL ON  turns optimizer on

\ : ;   ( -- )
\     TAILCALL @ 
\     IF 
\         PREVXT COLON?
\         IF   POSTPONE -;
\         ELSE POSTPONE ;
\         THEN 
\      ELSE 
\         POSTPONE ; 
\      THEN 
\ ; IMMEDIATE

