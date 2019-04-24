\ Machine Code macros for fast fetch, fast store and fast index
\ *These machine code  macros build Forth like instructions
\ that can be used in CODE word definitions

\
\ *WARNING* use these wisely. They can take 8 times more memory than
\ the equivalent Forth word. But if you need fast data access
\ they do the job for those specific data elements that need it.
\

\ INCLUDE DSK1.TOOLS.F

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

\ usage examples
VARIABLE X
VARIABLE Y

CODE X@    X @, NEXT, ENDCODE   \ 2x FASTER than X @
CODE Y!    Y !, NEXT, ENDCODE
