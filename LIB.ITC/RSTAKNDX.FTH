\ return stack index speed ups

\ The following word let us create faster loops with a counter on the rstack
\ Explanations
\ When using the return stack to maintain a loop index we have to pop
\ the value, increment it and push it back.  R> 1+ >R
\ In fact the address of the return stack is just a memory location and
\ so we can operate on easily if we know the address.

NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
NEEDS ELAPSE FROM DSK1.ELAPSE

CODE 'R  ( -- addr)
    TOS PUSH,
    RP TOS MOV,
    NEXT,
ENDCODE

CODE --R@   ( -- n)
    TOS PUSH,
   *RP DEC,
   *RP TOS MOV,
    NEXT,
    ENDCODE

CODE ++R@   ( -- n)
        TOS PUSH,
       *RP increment,
       *RP TOS MOV,
        NEXT,
        ENDCODE

\ Example
HEX
: TEST1 ( iterations -- ) \ 18 secs
     FFFF >R
     BEGIN
       R> 1- DUP >R
     0= UNTIL
     R> DROP ;

HEX
: TEST2 ( iterations -- ) \ 19.2 secs
      FFFF >R
      BEGIN
         -1 'R +!
      R@ 0= UNTIL
      R> DROP ;

: TEST3 ( iterations -- ) \ 10 secs
      FFFF >R
      BEGIN
         --R@
      0= UNTIL
     R> DROP ;

: TEST4    \ 9.2 SECS
      FFFF >R
      BEGIN
        --R@
      WHILE
      REPEAT
      R> DROP ;

: TEST5  FFFF 0 DO LOOP ;  \ 3.4 secs

: TEST6 ( iterations -- ) \ 18.6 secs
     FFFF >R
     BEGIN
       R> 1- >R
     R@ 0= UNTIL
     R> DROP ;
