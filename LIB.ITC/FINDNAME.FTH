\ findname.fth
NEEDS .S      FROM DSK1.TOOLS
NEEDS COMPARE FROM DSK1.COMPARE
NEEDS 4TH     FROM DSK1.3RD4TH

: 2OVER ( a b c d -- a b c d a b) POSTPONE 4TH  POSTPONE 4TH ; IMMEDIATE

: FIND-NAME ( addr len -- nfa ) \ nfa is "name field address"
           CONTEXT @ @  ( -- nfa )
           BEGIN 
             DUP C@         \ test word length byte
           WHILE ( len<>0)
              DUP>R  COUNT 2OVER 2OVER COMPARE 
           WHILE ( compare<>0)
              R> NFA>LFA @   ( follow link to next name)
           REPEAT
           THEN NIP NIP ;

: NFA>XT ( nfa -- XT -1|0|1)
          ?DUP 0= IF 0 EXIT THEN
          DUP NFA>CFA
          SWAP 1- C@ DUP 0= OR
;
