( CAMEL99 TINY HEAP    Apr 4 2017 BJF )
( simple code for ANS Forth ALLOCATE FREE RESIZE)

( Apr 5 2017   complete re-think             )
( Jan 26, 2018 fixed FREE, better factoring  )

HEX
3F10 CONSTANT HEND  \ end of HEAP

: CELL-  ( n -- n) COMPILE 2- ; IMMEDIATE

VARIABLE HLAST ( retains last allocated node address)

: HEAP        ( - adr) H @ ;   ( next free HEAP address)
: HALLOT      ( n - )  H +! ;
: H,          ( n - )  HEAP ! 2 HALLOT ;

: NLINK       ( node -- addr) CELL-  ;
: NSIZE       ( node -- addr) [ 2 CELLS ] LITERAL - ;

: INIT-HEAP   ( - )
              2000 H !
\              HEAP 1000 FF FILL ( for debugging)
              0 H,
              HEAP H,
              HEAP HLAST ! ;

: HFITS?      ( n - ) HEAP + HEND < ;

: NODE,       ( n -- addr)  \ create new node, return addr
              H, HLAST @ H,  HEAP ;

: (ALLOC)     ( n -- addr ?) \ un-conditional allocate primitive
              DUP NODE,      \ create node of n bytes
              DUP HLAST !    \ store node as last node
              SWAP HALLOT    \ allocate n bytes
              TRUE ;         \ return true always

: ALLOCATE ( N -- addr ?)
            DUP HFITS?       \ test for size
            IF   (ALLOC)
            ELSE  HEAP FALSE
            THEN ;

: ?NODE    ( node -- ) HLAST @ <> ABORT" Not last node" ;

: FREE     ( node -- ?)  ( NON-standard. Only frees last node)
            ?NODE
            HLAST @ NSIZE @ CELL+ NEGATE HALLOT
            HEAP CELL- HLAST !
            -1 ;

: RESIZE   ( n node -- ?)
            DUP ?NODE
            OVER HFITS?
            IF   2DUP NSIZE @ - HALLOT  ( allot the difference from old * new size)
                 NSIZE !                ( update node size field)
                 TRUE
            ELSE FALSE
            THEN ;

: HFREE   ( -- n ) HEND HEAP - ;

\ ==== Test code ====
DECIMAL
INIT-HEAP  

: .HEAP   ( -- ) CR  ." Free heap= "  HFREE U. ."  bytes" ;
 
 .HEAP
: MALLOC ( n -- addr) ALLOCATE 0= ABORT" Malloc fail!"  ;

  2 MALLOC CONSTANT X  ( integers)  ( better to use VALUES )
  2 MALLOC CONSTANT Y
  2 MALLOC CONSTANT Z
 50 MALLOC CONSTANT A$ ( strings)
.HEAP

99 X !   66 Y !  77 Z !
X ?   X NSIZE ?   A$ NSIZE ?

: PRINT ( string -- ) COUNT  CR TYPE ;

S" Now is the time for all good men to come to the aid of their country." A$ PLACE
CR  A$ PRINT

