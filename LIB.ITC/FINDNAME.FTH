\ findname.fth
NEEDS .S     FROM DSK1.TOOLS
NEEDS S=     FROM DSK1.COMPARE
NEEDS 4TH    FROM DSK1.3RD4TH

: 2OVER    ( a b c d -- a b c d a b) POSTPONE 4TH  POSTPONE 4TH ; IMMEDIATE

: FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
           CONTEXT @ @  ( -- nfa )
           BEGIN DUP
           WHILE ( tos<>0)
              DUP 1+ 2OVER S=
           WHILE ( compare<>0)
              NFA>LFA @   ( follow link to next name)
           REPEAT
           THEN NIP NIP ;

: NFA>XT ( nfa -- XT -1|0|1)
          ?DUP 0= IF 0 EXIT THEN
          DUP NFA>CFA
          SWAP 1- C@ DUP 0= OR
;
