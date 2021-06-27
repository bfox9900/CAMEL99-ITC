\ STACKS.FTH  for Camel99 Forth   B Fox 2019
HEX
: LIFO: ( #items -- )  \ "last in first out" creates a stack
         CREATE
            CELLS DUP , ( # of bytes in the stack)
            DUP       , ( stack offset )
            ALLOT  0  , ( safety cell  )
;

: CELL+@   ( addr -- addr' n )  CELL+ DUP @ ;
: CELL-    ( n -- n') [ 1 CELLS ] LITERAL - ;
: STACK-SIZE  ( 'stack -- n ) @ ;
: STACK-DEPTH ( stack-addr -- n ) 2@ - 2/ ABS ;

\ ANS Forth versions
\ : CELL+!  ( addr -- ) DUP @ [ 1 CELLS ] LITERAL + SWAP ! ;
\ : CELL-!  ( addr -- ) DUP @ [ 1 CELLS ] LITERAL - SWAP ! ;

\ Faster Camel99 Forth versions
 CODE CELL+!  ( addr -- ) 05D4 , C136 , NEXT, ENDCODE ( *TOS INCT, DROP, )
 CODE CELL-!  ( addr -- ) 0654 , C136 , NEXT, ENDCODE ( *TOS DECT, DROP, )

: PUSH  ( n stack-adr - )
        CELL+@ CELL- DUP 0= ABORT" User stack full"
        OVER CELL-! + ! ;

: POP   ( stack-adr -- n )
        DUP 2@ = ABORT" User stack empty"
        CELL+@ OVER CELL+! + @ ;

\ test code ...................
\ HEX
\  5 LIFO: Q
\  99 Q PUSH  100 Q PUSH   101 Q PUSH
\  Q STACK-DEPTH .
\  Q POP . Q POP . Q POP .
\  Q POP
