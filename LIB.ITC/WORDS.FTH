\ words.fth per Forth 2012.
\ Terms:
\ wid  wordlist indentifier
\ nt   name token  (ie Name field address)
INCLUDE DSK1.TOOLS

HEX
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: SPACEBAR ( -- ) KEY? BL = IF  KEY DROP  THEN ;
: GET-CURRENT ( -- addr) CURRENT @ @ ;

\ Remove wid and xt from the stack. Execute xt once for every word in the
\ wordlist wid, passing the name token nt of the word to xt, until the wordlist
\ is exhausted or until xt returns false.

\ ** This code is not fully compliant because the Name token is held on then
\    DATA stack.

: TRAVERSE-WORDLIST ( xt wid -- )
           SWAP >R
           BEGIN
              DUP
           WHILE
              ?BREAK SPACEBAR
              DUP R@ EXECUTE
              NFA>LFA @
           REPEAT
           R> 2DROP
;

\ prints the names of words in the current compilation wordlist.
: NAME>STRING ( nt -- ) COUNT 1F AND ;
: .ID      ( NFAaddr --)  NAME>STRING  TYPE SPACE  ;
: WORDS    ['] .ID   GET-CURRENT TRAVERSE-WORDLIST ;

\ print a count of the number of words in the FORTH-WORDLIST.
VARIABLE WC
: WC++   ( nfa -- )  DROP WC 1+! ;
: WORD-COUNT  ( -- ) WC OFF ['] WC++  GET-CURRENT TRAVERSE-WORDLIST WC @ . ;

\ print the name of a word containing the string "COM",
\ if it exists, and then terminates.
\ NEEDS SEARCH FROM DSK1.SEARCH
\:  CONTAINS-STRING
\   NAME>STRING 2OVER SEARCH IF 2DROP DUP .ID  THEN  ;

\ : WORDS-LIKE
\  PARSE-NAME  ['] CONTAINS-STRING GET-CURRENT TRAVERSE-WORDLIST ;
