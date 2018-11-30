\ pre-fab locals  NON-STANDARD but small code     B Fox 2017

\ Method:  
\ Create prenamed variables that refer to base+offset address
\ in a local stack space

CREATE LL0   16 CELLS 4* ALLOT    \ for nesting locals 4 levels deep

VARIABLE LSP       \ locals stack pointer
VARIABLE LBP       \ locals base pointer

: INT:  ( n -- )
        CREATE   ,
        DOES> @ CELLS LBP @ +  ;

0 INT: L0
1 INT  L1
2 INT: L2
3 INT: L3
4 INT: L4
5 INT: L5
6 INT: L6
7 INT: L7

: ->    ( n |text -- ) ?EXEC [']  @  ! ;

: LOCALS|  ( -- )
           LSP @ LBP !         \ current lstack is the base
           8 CELLS LSP +! ;    \ move the stack PTR. above the locals


: |END  ( -- )  LBP @ LSP !    \ restore lstack to the base
                ;

: INIT-LOCALS   LL0 LSP ! ;

INIT-LOCALS

: TEST  ( a b c --  )
   LOCALS| -> L0  -> L1  -> L2

   L0  L1 *  L2  +


   |END   ;

