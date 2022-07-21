\ ANS Dynamic Memory test
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

: ALLOCATE ( n -- addr ?) DUP H, HEAP SWAP HALLOT FALSE ;
\ *warning* FREE removes everything above it as well
 : FREE     ( addr -- ?) 2- DUP OFF  H ! FALSE ;
\ *warning* RESIZE will fragment the HEAP
 : RESIZE   ( n addr -- addr ?) DROP ALLOCATE ;
 : SIZE     ( addr -- n) 2- @ ; \ not ANS/ISO commonly found

\ A bit of protection  and syntax sugar
 : ?ALLOC ( ? --) ABORT" Allocate error" ;
 : ->     ( -- addr ?) ?ALLOC  POSTPONE TO ; IMMEDIATE
 CR HERE SWAP - DECIMAL . .( bytes)


\ DEMO CODE
HEX 2000 H !   \ reset heap pointer to the where you want the heap

\ dynamically allocate space for a string literal

: STRING:  ( addr len -- ) DUP ALLOCATE ?ALLOC DUP>R PLACE  R> VALUE ;
: PRINT    COUNT CR TYPE ;

DECIMAL
0 VALUE A$  ( create a null pointer )
0 VALUE B$
 80 ALLOCATE -> A$
 40 ALLOCATE -> B$
 A$ SIZE .
 B$ SIZE .

 S" This is string A$" A$ PLACE
 S" B$ is my name" B$ PLACE
 S" This string allocates itself" STRING: C$

 A$ PRINT
 CR
 B$ PRINT
 CR
 C$ PRINT
