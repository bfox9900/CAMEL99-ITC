\ tail call optimizing semicolon for Camel99 Forth  Nov 27 2022 Brian Fox

HEX
CODE GOTO   C259 ,  ( *IP IP MOV,)  NEXT, ENDCODE

: CELL-   2- ;
: PREVXT ( -- XT)  HERE CELL- @ ; \ fetch the XT of previous compiled word

: -;  ( -- ) \ programmer controlled
       PREVXT >BODY          \ get previous XT, compute data field
       -2 ALLOT              \ erase the previous XT
       POSTPONE GOTO  ,      \ compile the address for GOTO
       POSTPONE [            \ turn off compiler
       REVEAL
       ?CSP
; IMMEDIATE

: CODE?   ( xt -- ?) DUP @ CELL- = ;
: COLON?  ( xt -- ?) @ ['] DOCOL @ = ;

VARIABLE TAILCALL  \ control tail call optimizizing with this variable
                   \ TAILCALL ON  turns optimizer on

: TAILCALL? ( xt --?) ( DUP CODE? SWAP) COLON? ( OR)  TAILCALL @ AND ;

: ;   ( -- )
      PREVXT TAILCALL?
      IF   POSTPONE -;
      ELSE POSTPONE ;
      THEN ; IMMEDIATE

\ -; does not end with EXIT because it is branching directly to another
\ list of tokens. That other list will end in EXIT or NEXT.
