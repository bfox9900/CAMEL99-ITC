\ SEARCH-WORDLIST  16.6.1.2192
\ Find the definition identified by the string c-addr u in
\ the word list identified by wid. If the definition is not found,
\ return zero. If the definition is found, return its execution
\ token xt and one (1) if the definition is immediate,
\ minus-one (-1) otherwise.

NEEDS .S     FROM DSK1.LOWTOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS COMPARE FROM DSK1.COMPARE

: FIND-NAME ( addr len wid -- nfa )
   BEGIN
      DUP>R
   WHILE
      2DUP R@ COUNT COMPARE
   WHILE
      R> NFA>LFA @
   REPEAT
   THEN
   2DROP
   R>
;

: NFA>XT ( nfa -- XT -1|0|1)
   ?DUP 0= IF 0 EXIT THEN
   DUP NFA>CFA
   SWAP 1- C@ DUP 0= OR
;

: SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1)
   FIND-NAME NFA>XT
;
