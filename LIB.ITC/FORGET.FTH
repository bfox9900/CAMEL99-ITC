\ FORGET    erase dictionary up a given word
\ changed LATEST to CONTEXT @ for V2.66 with wordlists
HEX
: CFA>NFA ( cfa -- nfa | 0 ) 2- BEGIN   1- DUP C@ 0FE AND  0= UNTIL 1+  ;
: FORGET   '   CFA>NFA  NFA>LFA DUP @ ( nfa) CONTEXT @ ! ( lfa ) DP ! ;
 
