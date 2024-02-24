\ fastvars.fth

INCLUDE DSK1.LOWTOOLS

: @,    TOS PUSH,  ( addr ) @@ TOS MOV, ;
: !,    TOS SWAP @@ MOV, TOS POP,   ;

VARIABLE X
VARIABLE Y

\ create fast variable words
CODE X@   X @,  NEXT, ENDCODE
CODE Y@   Y @,  NEXT, ENDCODE

CODE X!    X !,  NEXT, ENDCODE
CODE Y!    Y !,  NEXT, ENDCODE

INCLUDE DSK1.ELAPSE

: TEST1   32000 0 DO  X @ DROP LOOP ; \ 5.40
: TEST2   32000 0 DO  Y@ DROP  LOOP ; \ 4.38  23% faster
: TEST3   32000 0 DO  99 X ! LOOP ;   \ 6.28
: TEST4   32000 0 DO  99 Y!  LOOP ;   \ 4.66  35% faster 
