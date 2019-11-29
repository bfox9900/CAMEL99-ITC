\ TRAVERSE the forth dictionary and execute a routine on each word

NEEDS .S     FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE

: COMPARE$ ( $1 $2 -- flag) S" DUP C@ 1+ S=" EVALUATE ; IMMEDIATE

: TRAVERSE  ( addr len -- nfa )  \ 4.4x SLOWER than ASM (FIND)
             PAD PLACE        \ store string we are looking for
             LATEST @
             BEGIN
                DUP PAD COMPARE$
             WHILE
                NFA>LFA @     \ follow the links
                .ID
                DUP 0= IF EXIT THEN
             REPEAT ;
