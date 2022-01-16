\ Minimalist ALLOCATE FREE RESIZE for Camel99 Forth B Fox Sept 3 2020
\ One-time Static allocation

NEEDS VALUE FROM DSK1.VALUES

HERE
HEX
: HEAP,    ( n --) H @ !  [ 1 CELLS ] LITERAL  H +! ;
: ALLOCATE ( n -- addr ?) DUP HEAP, H @   SWAP H +!  FALSE ;
\ *warning* FREE removes everything above it as well
: FREE     ( addr -- ?) 2- DUP OFF  H ! FALSE ;
\ *warning* RESIZE will fragment the HEAP
: RESIZE   ( n addr -- addr ?) DROP ALLOCATE ;
: SIZE     ( addr -- n) 2- @ ; \ not ANS/ISO commonly found

\ A bit of protection and syntax sugar.
 : ?ALLOC ( ? --) ABORT" Allocate error" ;

\ Use -> as replacement for 'TO' values 
\ Example: 99 -> X
 : ->     ( -- addr ?) ?ALLOC  POSTPONE TO ; IMMEDIATE

CR HERE SWAP - DECIMAL . .( bytes)
