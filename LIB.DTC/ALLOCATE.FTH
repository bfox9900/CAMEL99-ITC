\ =================================================================
\ Minimal ALLOCATE FREE RESIZE                        BJF Aug 2016

\ If you try to FREE a node that is not the last node it will blow
\ away the ones below. Just like FORGET

\ If you RESIZE an item that is not the last NODE you get an ERROR

\ =================================================================
\ *** SET MEMTOP FOR YOUR SYSTEM ***

\ ERROR constants
        69 CONSTANT ALLOCATE_ERR
        79 CONSTANT HEAP_OVERFLOW
        89 CONSTANT FREE_ERROR
        99 CONSTANT RESIZE_ERROR
       200 CONSTANT HGAP

     2 CELLS CONSTANT NODE_SIZE
 NODE_SIZE - CONSTANT ROOTNODE

VARIABLE LASTNODE

: HEAP        ( -- addr ) HP @ ;
: HALLOT      ( n -- )    HP +! ;
: HEAP,       ( n -- )    HEAP ! CELL HALLOT ;
: HEND        ( -- n )    HERE HEAP + ;
: ?EOH        ( u -- ? )  HEND  U< ;
: HLINK       ( addr --)  LASTNODE @ HEAP, NODE_SIZE + LASTNODE ! ;
: LASTNODE?   ( addr -- ?) LASTNODE @ = ;
: HEAP-SIZE   ( -- u )     HEAP HEND  - ;
: ALLOCATION  ( node -- addr)  CELL - ;
: ALLOCATED   ( node --  u )   ALLOCATION @ ;
: >PREV       ( node -- addr') NODE_SIZE - ;

: INIT-HEAP   ( --)
               MEMTOP HP !
               0 HEAP,                  \ root node size
               0 HEAP,                  \ root node link
               ROOTNODE LASTNODE ! ;

: ALLOCATE    ( u -- a-addr ior )
              HEAP over -
              ?eoh
              if
                  ALLOCATE_ERR
              ELSE
              ( u) DUP HALLOT HEAP,     \ allot & record size in the node
                   HEAP hlink           \ link back to the old NODE
                   LASTNODE @ 0         \ return the HEAP pointer and 0
              THEN ;

: RESIZE    ( addr u -- addr ior)
            CELL MAX
            OVER LASTNODE?
            IF 2DUP -  ?EOH
               IF  DROP RESIZE_ERROR
               ELSE
                  OVER ALLOCATED OVER - HP +!
                  OVER ALLOCATION !
                  FALSE
               THEN
            ELSE
               DROP RESIZE_ERROR
            THEN ;

INIT-HEAP

TRUE [IF]
\ this version of FREE has no error checking
: FREE      ( addr -- ior)
               >prev @
               dup HP !  lastnode !
               false  ;

[ELSE]
\ *SAFE* version of FREE checks if addr is a valid node
: NODE?    ( node -- ? )
              dup lastnode?
              if drop true
              else
                 0 >r
                 lastnode @
                 begin >prev @ dup
                 while 2dup = if  r> 1- >r  then
                 repeat
                 2drop
                 r>
              then ;
              
: ?NODE     ( addr -- addr)
            dup NODE? 0=
            if  cr ." Addr=" 5 u.r
                true abort" Invalid HEAP node"
            then ;


: FREE      ( addr -- ior)  \ SAFE version
            dup node?
            if
                >prev @
                dup HP !
                lastnode !
                false
            else
                drop free_error
            then ;

[THEN]
\ ==============================================================

TRUE [if]
\ ==============================================================
\ test code

: .HEAP    ( -- ) cr ." HEAP free= " HEAP-SIZE U. ;

INIT-HEAP
.Heap

\ usage examples
: malloc    ( bytes -- addr ) allocate  abort" Malloc failed" ;

: calloc    ( #elements size -- addr )
            * allocate abort" Calloc failed"
            dup dup ALLOCATED erase ;

2000 malloc value q
2000 malloc value w
 300 malloc value t

\ count nodes backwards
:  #NODES  ( -- n)
           0 >R
           LASTNODE @
           BEGIN
              >PREV @ DUP
           WHILE
              R> 1+ >R
           REPEAT
           R> ;

\ show the addresses and sizes
: .node   ( node -- )  dup 6 u.r  TAB  dup ALLOCATED 5 .r  TAB  >prev @ 6 u.r ;

: .nodes
           cr ."  Node    Bytes   Link"
           cr
           lastnode @
           begin
               cr dup .node
               >prev @
           dup 0= until
           2drop
           CR ." Total nodes = " #nodes .
           CR .HEAP ;
           
: ALLOCATIONS  0 ?DO  100 malloc  loop ;

: releases     0 ?do  FREE abort" FREE failed"  loop ;

: TESTs        0 ?do  cr .HEAP  85 allocations  tab .HEAP  85 releases  loop ;


[then]




