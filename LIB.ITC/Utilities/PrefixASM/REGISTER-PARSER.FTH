\ REGISTER PARSER
CHAR * CONSTANT '*'
CHAR + CONSTANT '+'
CHAR R CONSTANT 'R'

: LASTCHAR ( $ n -- $ n c) 2DUP COUNT + 1- C@ ;

VARIABLE AMODE

: ADRMODE ( $ n -- mode )
    AMODE OFF
    '*' MATCH
    IF  **  AMODE !   \ indirect operator
        LASTCHAR '+' =
        IF
            *+  AMODE ! \ indirect, auto-inc
            1-       \ cut string len. removing '+'
        THEN
    THEN
    EVALUATE
    AMODE @ IF AMODE @ THEN
;
