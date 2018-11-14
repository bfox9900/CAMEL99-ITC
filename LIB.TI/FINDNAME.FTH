
: COMPARE$ ( $1 $2 -- flag) S" DUP C@ 1+ S=" EVALUATE ; IMMEDIATE

: FIND-NAME  ( -- nfa )
             [CHAR] " PARSE  PAD PLACE
             LATEST @
             BEGIN
                DUP ( -- nfa nfa) PAD COMPARE$
             WHILE
                NFA>LFA @  \ follow the links
             REPEAT ;
