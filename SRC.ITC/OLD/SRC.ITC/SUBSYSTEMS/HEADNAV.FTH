\ H E A D E R   N A V I G A T I O N

TARGET-COMPILING
\ : NFA>LFA       ( nfa -- lfa)  3 - ;
CODE NFA>LFA    TOS -3 ADDI, NEXT, ENDCODE  ( faster, same size)
\ Changed 7F to 1F . 31 character max name length. Other bits for future use
: NFA>CFA       ( nfa -- cfa ) COUNT  1F AND + ALIGNED ;

\ smudge bit control in the Camel Forth
: HIDE          ( -- )  LATEST @ ( nfa) DUP C@ 80 OR  SWAP C! ;
: REVEAL        ( -- )  LATEST @ ( nfa) DUP C@ 7F AND SWAP C! ;
