\ VALUEs for CAMEL99 fast version uses 36 more bytes    Feb 2022 Brian Fox
\ TO is ~3X faster
\ Usage:  0 VALUE W
\           99 TO W   1 +TO W

HERE
HEX
CODE LIT!  (  n -- ) \ combine function of LIT and !
    C079 , \ *IP+  R1 MOV,
    C444 , \  TOS  R1 ** MOV,
    C136 , \  TOS POP,
    NEXT,
ENDCODE

.( .)
: VALUE  ( n --)  HEADER  COMPILE DOCON  COMPILE, ;

: TO  ( n -- )
           ' >BODY   \ compute PFA at compile time
           STATE @
           IF  POSTPONE LIT!  COMPILE,  EXIT
           THEN  ! ; IMMEDIATE
 .( .)
\ comment these if you don't need them
CODE LIT+!  ( n addr --) \ combine functions LIT and +!
    C079 ,  \  *IP+  R1 MOV,
    A444 ,  \  TOS  R1 ** ADD,
    C136 ,  \  TOS POP,
    NEXT,
ENDCODE

: +TO      ( n -- )
           ' >BODY
           STATE @
           IF   POSTPONE LIT+!  COMPILE,  EXIT
           THEN  +! ; IMMEDIATE
 .( .)
HERE SWAP -  SPACE DECIMAL . .( bytes) HEX
