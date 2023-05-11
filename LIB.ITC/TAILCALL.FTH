\ tail call optimizing semicolon for Camel99 Forth  Nov 27 2022 Brian Fox

HEX
CODE GOTO ( addr -- )  C259 ,   NEXT, ENDCODE  ( *IP IP MOV,)

: CELL-   2- ;
: PREVXT ( -- XT)  HERE CELL- @ ; \ fetch the XT of previous compiled word

: -;  ( -- )                 \ programmer controlled
       PREVXT >BODY          \ get previous XT, compute data field
       -2 ALLOT              \ erase the previous XT
       POSTPONE GOTO  ,      \ compile the address for GOTO
       POSTPONE [            \ turn off compiler
       REVEAL
       ?CSP
; IMMEDIATE

: COLON?  ( xt -- ?) @  [ ' DOCOL @ ] LITERAL = ;

VARIABLE TAILCALL  \ control tail call optimizizing with this variable
                   \ TAILCALL ON  turns optimizer on

: ;   ( -- )
     TAILCALL @ 
     IF 
         PREVXT COLON?
         IF   POSTPONE -;
         ELSE POSTPONE ;
         THEN 
      ELSE 
         POSTPONE ; 
      THEN 

; IMMEDIATE

