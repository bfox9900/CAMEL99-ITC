\ findname.fth
NEEDS S=     FROM DSK1.COMPARE

: 2OVER    ( a b c d -- a b c d a b) 3 PICK  3 PICK ;
: 2NIP     ( a b c -- c)  NIP NIP ;

: FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
           LATEST @
           BEGIN
              DUP 1+ 2OVER S=
              0= IF  2NIP  EXIT THEN
              NFA>LFA @   ( next name in dictionary)
              DUP
           0= UNTIL
           2NIP  ;

: NFA>XT ( addr -- XT -1|0|1)
          DUP 1- C@ 0= IF TRUE ELSE 1 THEN
          SWAP NFA>CFA SWAP ;
