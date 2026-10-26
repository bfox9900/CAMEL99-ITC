\ FETCHER.FTH  faster fetching and storing   Oct 26 2026
\ Machine Code macros for fast fetch, using TMS9900 symbolic addressing

\
\ *WARNING* use these wisely. They can take 8 times more memory than
\ the equivalent Forth word. But if you need fast data access
\ they do the job for those specific data elements that need it.
\

NEEDS DUMP FROM DSK1.TOOLS

\ *These machine code  macros build Forth like instructions
\ that can be used in CODE word definitions
HEX
\ fetch value from the address in the code
: @,   ( addr -- n)        \ 8 bytes
         0646 ,  C584 ,    \ TOS PUSH,
         C120 , ( addr) ,  \ ( n) @@ TOS MOV,
;

\ store number in TOS to addr
: !,   ( addr --)
         C804 , ( addr) , \ TOS addr @@ MOV,
         C136 ,           \ TOS POP,
;

\ char array indexed fetch
: []C@, ( addr -- n )     \ 4 bytes
        C124 , ( addr) ,  \ addr(TOS) TOS MOVB

;

\ char array indexed store
: []C!, ( addr -- ) \ 6 bytes
        C936 , ( addr) ,  \ *SP+ Q (TOS) MOVB,
        C136 ,            \ TOS POP,  refill TOS register
;

\ Words that build new CODE words :-)
: FETCHER:  ( addr -- <name>) CODE     @,  NEXT,  ;
: STORER:   ( addr -- <name>) CODE     !,  NEXT,  ;

\ usage examples
VARIABLE X

X FETCHER: X@
X STORER: X!

NEEDS ELAPSE FROM DSK1.ELAPSE

HEX
: TEST1  4000 0 DO  X @ DROP LOOP ; \ 2.71
: TEST2  4000 0 DO  X@ DROP LOOP ;  \ 2.26 secs 19% faster


: TEST3  4000 0 DO  99 X ! LOOP ;  \ 3.23 secs
: TEST4  4000 0 DO  99 X!  LOOP ;  \ 2.41 34% faster
