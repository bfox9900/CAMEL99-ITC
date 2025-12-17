\ tail call optimizing semicolon for Camel99 Forth  Nov 27 2022 Brian Fox

HEX
CODE GOTO   ( *IP+ IP MOV,)  C279 , NEXT, ENDCODE

DECIMAL
\ fetch the XT of previous compiled word
: PREVXT ( -- XT)  HERE 1 CELLS - @ ;

\ ** THIS WON'T CATCH CODE WORDS IN SCRATCH PAD RAM **
: ?CODE ( xt -- xt ?) DUP @ OVER - 2 = ABORT" Can't tail call a code word" ;

\ -; does not end with EXIT because it is branching directly to another
\ list of tokens. That other list will end in EXIT or NEXT.
: -;  ( -- ) \ programmer controlled
      PREVXT ?CODE
      >BODY                     \ get previous XT, compute PFA
      -1 CELLS ALLOT            \ erase the previous XT
      POSTPONE GOTO  ( pfa) ,   \ compile jump to the PFA
      POSTPONE [                \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE

\ EXAMPLE CODE
\ : WORD1 CR ." word 1 " ;
\ : WORD2 CR ." word 2 " ;
\ : WORD3 CR ." word 3 " ;
\ : WORD4 CR ." word 4 " ;

\ VARIABLE X
\ : TEST   WORD1  WORD2 WORD3 WORD4 -;
\ : TEST2  99 X  WORD1  WORD2 WORD3 WORD4 ! -; \ aborts
