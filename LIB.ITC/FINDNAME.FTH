\ findname.fth
NEEDS S=     FROM DSK1.COMPARE

: 2OVER    ( a b c d -- a b c d a b) 3 PICK  3 PICK ;
: 2NIP     ( a b c -- c)  NIP NIP ;

\ : FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
\           LATEST @
\           BEGIN
\              DUP 1+ 2OVER S=
\              0= IF  2NIP  EXIT THEN
\              NFA>LFA @   ( next name in dictionary)
\              DUP
\           0= UNTIL
\           2NIP  ;

\ better version uses ISO while with 2 condition tests
: FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
           XLATEST @  ( -- NFA )
           BEGIN DUP
           WHILE ( tos<>0)
              DUP 1+ 2OVER S=
           WHILE ( compare<>0)
              NFA>LFA @   ( follow link to next name)
           REPEAT
           THEN 2NIP  ;

: NFA>XT ( nfa -- XT -1|0|1)
          DUP 1- C@ 0= IF TRUE ELSE 1 THEN
          SWAP NFA>CFA SWAP ;
