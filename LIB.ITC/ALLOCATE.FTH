\ Minimalist ALLOCATE FREE RESIZE for Camel99 Forth B Fox Sept 3 2020
\ Static allocation, size function and crude re-sizing
\ Use with VALUE or CONSTANT to retain the pointers

HEX
HERE
: HEAP   ( -- addr)  H @ ;  \ equivalent to HERE but in LOW RAM
: HALLOT ( n -- )    H +! ; \ equivalent to ALLOT but in LOW RAM
\ : HALIGN ( -- )   HEAP ALIGNED H ! ;
: CELL-  ( n -- n') [ 1 CELLS ] LITERAL - ;

\ heap number "compilers". Put a number in memory & advance the pointer
: H,     ( n -- )  HEAP !   2 HALLOT ;
: HC,    ( n -- )  HEAP C!  1 HALLOT ;

: ?HEAP ( n --) HEAP OVER + 3FFF > ABORT" HEAP full" ;

\ *Dec 2022 ALLOCATE only even amounts of memory 
: ALLOCATE ( n -- addr ?) ?HEAP  ALIGNED DUP H, HEAP SWAP HALLOT FALSE ;

\ *warning* FREE removes everything above it as well
 : FREE     ( addr -- ?) CELL- DUP OFF  H ! FALSE ;
\ *warning* RESIZE will fragment the HEAP
 : RESIZE   ( n addr -- addr ?) DROP ALLOCATE ;
 : SIZE     ( addr -- n) CELL- @ ; \ not ANS/ISO commonly found

 CR HERE SWAP - DECIMAL . .( bytes)
