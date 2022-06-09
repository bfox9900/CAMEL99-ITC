\ assign.fth
HEX
CODE :=    ( addr1 addr2 --)  \ 10X FASTER THAN X @ Y !
 C236 ,  \       W POP,
 C518 ,  \ *W *TOS MOV,
 C136 ,  \      TOS POP,
 NEXT,
ENDCODE

: FETCH,  \ TOS PUSH,  ( addr ) @@ TOS MOV, NEXT,  ;
         0646 , C584 ,  C120 ,  ( addr) , NEXT, ;

: STORE,    TOS SWAP @@ MOV, TOS POP,  NEXT,  ;

VARIABLE X
VARIABLE Y

X CODE X@    FETCH,
Y CODE Y@    FETCH,

X CODE X!    STORE,
Y CODE X!    STORE,

: TEST1   8000 0 DO  X @ DROP LOOP ; \ 5.56
: TEST2   8000 0 DO  X@ DROP  LOOP ; \ 4.65  19% faster 
