\ FIG Forth style VOCABULARY FOR CAMEL99
\ the simplest form of VOCABULARY.
 **DOES_NOT_WORK** 
\ Each new Vocabulary links back to Forth

NEEDS .S FROM  DSK1.TOOLS

HEX
DECIMAL
  VARIABLE WID-LINK   \ Pointer to the most recently defined wordlist

: WORDLIST ( -- wid)
   HERE  0 ,                \ nfa of last word defined in wordlist
   WID-LINK @ , WID-LINK !  \ link to previous wordlist
   LATEST @ ,               \ compile NFA of the name of this wordlist
;

CREATE FORTH WORDLIST     CONTEXT @  FORTH !

: VOCABULARY
  CREATE
       HERE  FORTH ,     \ nfa of last word defined in wordlist
       WID-LINK @ , WID-LINK !  \ link to previous wordlist
       LATEST @ ,               \ compile NFA of the name of this wordlist
       DOES> @ CONTEXT @ ! ;

: DEFINITIONS  ( -- ) CONTEXT @ CURRENT ! ;
