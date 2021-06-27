\ SEARCHWORDLIST.fth we need find-name to patch some CONTEXT values

NEEDS S=     FROM DSK1.COMPARE

: 2OVER    ( a b c d -- a b c d a b) 3 PICK  3 PICK ;
: 2NIP     ( a b c -- c) NIP NIP ;

: SEARCH-WORDLIST ( addr len -- nfa ) \ nfa is "name field address"
           BEGIN
              DUP 1+ 2OVER S=
              0= IF  2NIP  EXIT THEN
              NFA>LFA @   ( next name in dictionary)
              DUP
           WHILE
           REPEAT
           2NIP  ;
