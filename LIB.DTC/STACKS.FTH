\ LIFO.FTH   for CAMEL99 Forth

: LIFO: ( #items -- )
         CREATE
            CELLS DUP , ( # of cells in the stack)
            CELL+ DUP , ( max items on stack )
            ALLOT   0 , ( stack pointer)
;

: CELL+@   ( addr -- addr' n )  CELL+ DUP @ ;
: CELL-    ( n -- n') 2- ; 
: STACK-SIZE  ( 'stack -- n ) @ ;
: STACK-DEPTH ( 'stack -- n ) CELL+@ ;

: 2+!         ( addr -- ) DUP @ 2+ SWAP ! ;
: 2-!         ( addr -- ) DUP @ 2- SWAP ! ;

: ?UNDERFLOW  ( stack-addr -- ) DUP 2@ = ABORT" user stack empty" ;

: PUSH  ( n stack-adr - )
        CELL+@ CELL- DUP 0= ABORT" User stack full"
        OVER 2-! + ! ;

: POP   ( stack-adr -- n ) ?UNDERFLOW CELL+@ OVER 2+!  ;


\ test code ........................
       CR ." CREATE STACK CALL 'QQ'"
       100 LIFO: QQ

       99 QQ PUSH
       100 QQ PUSH
       101 QQ PUSH
       CR ." STACK QQ DEPTH = " QQ STACK-DEPTH .
       CR ." POP 3 ITEMS"
       
       CR QQ POP . QQ POP . QQ POP .

       CR ." PRESS ANY KEY TO SHOW UNDERFLOW ERROR"
       KEY DROP

       CR QQ POP

