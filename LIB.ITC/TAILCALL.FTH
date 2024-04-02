\ tail call optimizing semicolon for Camel99 Forth  Nov 27 2022 Brian Fox

DECIMAL 
\ fetch the XT of previous compiled word
: PREVXT ( -- XT)  HERE 1 CELLS - @ ; 

\ -; does not end with EXIT because it is branching directly to another
\ list of tokens. That other list will end in EXIT or NEXT.
: -;  ( -- ) \ programmer controlled
      PREVXT >BODY              \ get previous XT, compute PFA
     -1 CELLS ALLOT             \ erase the previous XT
      POSTPONE BRANCH HERE - ,  \ compile BRANCH to the PFA
      POSTPONE [                \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE

\ >> smart version but DOES NOT WORK WITH DEFER WORDS 

\: COLON?  ( xt -- ?) @  [ ' DOCOL @ ] LITERAL = ;
\ VARIABLE TAILCALL  \ control tail call optimizizing with this variable
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

\ TAILCALL ON 

