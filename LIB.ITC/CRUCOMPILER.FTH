\ CRU compile experiment to speed up CRU operations in Forth
: ;CODE
            POSTPONE (;CODE)     \ compiles (;CODE) into definition
            ?CSP POSTPONE [      \ turns off the Forth compiler
            REVEAL               \ (just like ";" does)
            ; IMMEDIATE          \ this is an IMMEDIATE word

8 10 + CONSTANT *W               \ R8 is Forth "working" register

: CRU,   SWAP 00FF AND OR , ;

: B,     ( register -- ) 0440 +  , ;   \ branch to register instruction compiler

: TESTER:     CREATE   1F00  CRU, NEXT,
            ;CODE
              *W  B,
            ENDCODE

: SETTER:   CREATE  1D00 CRU, NEXT,
            ;CODE
               *W  B,
            ENDCODE

: RE-SETTER: ( bit# -- )
            CREATE  1D00 CRU, NEXT,
            ;CODE
               *W  B,
            ENDCODE
DECIMAL
 7 TESTER: 7TB
27 TESTER: 7TB

21 SETTER: 21SBO

31 SETTER: 31SBO
