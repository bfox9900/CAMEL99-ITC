\ BEHEAD.fth  "HIDES" words in the dictionary   13JUL2022
HEX
NEEDS CFA>NFA  FROM DSK1.FORGET
\ : CFA>NFA ( cfa -- nfa | 0 ) 2- BEGIN  1- DUP C@ 0FE AND  WHILE REPEAT 1+  ;

: BEHEAD  ( <word1> <word2> ) \ remove words BETWEEN <word1> & <words2>
         '     '
        2DUP < IF 2SWAP THEN  \ get the order correct
        CFA>NFA  SWAP  CFA>NFA NFA>LFA  ( nfa2 lfa1 ) ! ;
DECIMAL
