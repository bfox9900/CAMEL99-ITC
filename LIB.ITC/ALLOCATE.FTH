\ Minimalist ALLOCATE FREE RESIZE for Camel99 Forth B Fox Sept 3 2020
\ Static allocation, size function and crude re-sizing
\ Use with VALUE to retain the pointers

NEEDS VALUE FROM DSK1.VALUES

HEX
HERE
: HEAP   ( -- addr)  H @ ;  \ equivalent to HERE in HI memory
: HALLOT ( n -- )    H +! ; \ equivalent to ALLOT in HI memory
: HALIGN ( -- )   HEAP ALIGNED H ! ;

\ heap number "compilers". Put a number in memory & advance the pointer
: H,     ( n -- )  HEAP !   2 HALLOT ;
: HC,    ( n -- )  HEAP C!  1 HALLOT ;

: ?ALLOC ( n --) HEAP OVER + 3FFF > ABORT" Allocate error" ;
: ALLOCATE ( n -- addr ?) ?ALLOC  DUP H, HEAP SWAP HALLOT FALSE   ;
\ *warning* FREE removes everything above it as well
 : FREE     ( addr -- ?) 2- DUP OFF  H ! FALSE ;
\ *warning* RESIZE will fragment the HEAP
 : RESIZE   ( n addr -- addr ?) DROP ALLOCATE ;
 : SIZE     ( addr -- n) 2- @ ; \ not ANS/ISO commonly found

 CR HERE SWAP - DECIMAL . .( bytes)
