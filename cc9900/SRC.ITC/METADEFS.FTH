\                     M E T A  D E F I N I T I O N S
\ META definitions look like Forth words but do cross-compiler actions
\ META wordlist is searched first while TARGET-COMPILING, so these IMMEDIATE
\ words always run first.


CROSS-COMPILING ALSO META DEFINITIONS
CR .( compiling META Definitions )

: ."          POSTPONE T." ; IMMEDIATE
: S"          POSTPONE TS" ; IMMEDIATE
: [']         POSTPONE t['] ; IMMEDIATE
: CHAR        TCHAR ;
: [CHAR]      ?XCOMP TCHAR  POSTPONE TLITERAL ; IMMEDIATE
: [COMPILE]   POSTPONE  T[COMPILE] ; IMMEDIATE

\ : CREATE      POSTPONE TCREATE:  ;  IMMEDIATE 
\ : ,        POSTPONE T,  ; IMMEDIATE 
\ : C,       POSTPONE TC, ; IMMEDIATE 

: TRUE   -1 ; IMMEDIATE 
: FALSE   0 ; IMMEDIATE 

CROSS-COMPILING
