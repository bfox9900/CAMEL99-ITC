\ STACKS.FTH    for FbForth     B Fox 2019

\ primitives
: CELLS   1 SLA ;
: 2/      1 SRA ; 
: CELL+   2+ ;
: CELL-   2- ;
: 2@ ( adr -- n1 n2 )   DUP 2+ @ SWAP @ ;

: LIFO: ( #items -- )  \ "last in first out" creates a stack
         <BUILDS
            CELLS DUP , ( # of bytes in the stack)
                  DUP , ( max items on stack )
            ALLOT   0 , ( safety cell ? )
         DOES>
;

: CELL+@   ( addr -- addr' n )  CELL+ DUP @ ;
: STACK-SIZE  ( 'stack -- n ) @ ;
: STACK-DEPTH ( stack-addr -- n ) 2@ - 2/ ABS ;

  : 2+!  ( addr -- ) DUP @ 2+ SWAP ! ;
  : 2-!  ( addr -- ) DUP @ 2- SWAP ! ;

: PUSH  ( n stack-adr - )
        CELL+@ CELL- DUP 0= ABORT" User stack full"
        OVER 2-! + ! ;

: POP   ( stack-adr -- n )
        DUP 2@ = ABORT" User stack empty"
        CELL+@ OVER 2+! + @ ;

\ test code ...................
DECIMAL
  10 LIFO: Q

  99 Q PUSH  100 Q PUSH   101 Q PUSH

   Q STACK-DEPTH .

  Q POP . Q POP . Q POP .
  Q POP

