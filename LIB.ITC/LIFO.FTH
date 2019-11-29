\ LIFO.FTH   for CAMEL99 Forth

INCLUDE DSK1.TOOLS

: LIFO: ( #items -- )
         CREATE
            CELLS DUP , ( # of cells in the stack)
                  DUP , ( max items on stack )
            ALLOT   0 , ( stack pointer)
;

: CELL+@   ( addr -- addr' n )  CELL+ DUP @ ;
: CELL-    ( n -- n') 2- ;
: STACK-PTR  ( 'stack -- n ) 2+ DUP @ ;
: STACK-DEPTH ( 'stack -- n ) 2@ - ABS 2/  ;

\ 9900 can do these in 1 instruction ( *TOS INCT, *TOS DECT)
CODE 2+!  ( addr -- ) 05D4 , NEXT, ENDCODE
CODE 2-!  ( addr -- ) 0654 , NEXT, ENDCODE

\ : 2+!         ( addr -- ) DUP @ 2+ SWAP ! ;
\ : 2-!         ( addr -- ) DUP @ 2- SWAP ! ;

: ?UNDERFLOW  ( stack-addr -- ) DUP 2@ = ABORT" user stack empty" ;

: PUSH  ( n stack-adr - )
        stack-ptr CELL- DUP 0= ABORT" User stack full"
        OVER 2-! + ! ;
\ : push  ( n stack-adr - )
\        stack-ptr cell- DUP 0= ABORT" Argument stack full"
\        OVER 2-! I! ;

: POP   ( stack-adr -- n ) ?UNDERFLOW STACK-PTR OVER 2+! + @  ;
\ : pop   ( stack-adr -- n ) ?underflow stack-ptr over 2+! i@ ;

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

