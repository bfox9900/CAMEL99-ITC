\ Cons cells a.k.a. linked lists
\ by Chris Walton
\
\ Cons cells have two items. car is the first, cdr, the second.
\ Use cxr! to store to a cell, cxr@ to read from it.
\ CONS returns the address of a newly created cons cell from 2 cells given
\ cons0 as above, but uses 0 instead of given arguments.
\ 
\ Linked lists can be made by having first item be data, second link to next.
\ Double linked lists will have a link to a cell in cdr describing 
\ both previous and next. 
\ This thing is infinetely extendable - use it to your advantage.
\
\ Compatibility:
\ Added words to make these work with CAMEL99 Forth BJF

 : THROW ( ? -- ) ABORT" Allocation error" ;

\ : TUCK SWAP OVER ;  \ in the CAMEL99 Kernel

\ make space for a bunch of CONS
2 CELLS CONSTANT CONSIZE

HEX   1000 CONSIZE *  MALLOC CONSTANT CONS[]  \ array of CONS data types
CONSARRAY CONSIZE +          CONSTANT ENDCONS

CONS[] CREATE LP  ,   ( free list pointer init to consarry)


: CAR  ( addr - v ) @ ;         \ POINTER to data
: CDR  ( addr - v ) CELL+ @ ;   \ POINTER to next item

: CAR!  ( v addr - ) ! ;        \ store something in CAR
: CDR!  ( v addr - ) CELL+ ! ;  \ store something in CDR

VARIABLE FREELINK    \ Holds the current FREELINK to use
VARIABLE LASTLINK    \ added lastlink so we can keep track of usage

: CONS+  ( n -- n') CONSSIZE + ;  \ for clarity in the code
: ERASE  ( addr  0 FILL ;

: INIT-LISTS ( --)   \ initializes the free list with all cells.
            CONS[] CONSIZE ERASE   \ erase the links buffer
            CONS[]
            #LINKS 1- 0            \ link all CONS but last one
            DO
               DUP CONS+ OVER !
               CONS+
            LOOP
            DUP LASTLINK !
            NIL SWAP !             \ last CONS contains NIL
            CONS[] FREELINK !  ;   \ start of buffer is the first FREELINK

: LALLOT  ( n -- )  LP +! ;

: ALLOCATE ( n -- addr ?)
            LP @  2DUP +  ENDCONS >
            IF   2DROP 0 TRUE
            ELSE LALLOT  FALSE
            THEN ;

: CONS  ( k v - addr ) SWAP 2 CELLS ALLOCATE THROW TUCK ! TUCK ! ;
: CONS0 ( - addr ) 0 0 CONS ;

: NIL   0 0  ;    \ nil list

: {   ( -- ) !CSP  ;    \ list starts with 0 in link-fld, record stack pos.
: }   ( -- ) {NIL} CDR!  ?CSP ;     \ ends list, check stack

: '{  ( -- addr) !CSP CONS0 ;

: "   ( -- addr )             \ make a link-list string
      [CHAR] " PARSE-WORD      ( -- addr len)
      HERE -ROT S, ;          \ compile the string into memory
