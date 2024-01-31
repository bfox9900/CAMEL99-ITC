\ bubble sort challenge by Sam Falvo  Circa 2008
\ https://wiki.c2.com/?BubbleSortChallenge

( source code case changed for Camel99 Forth )

INCLUDE DSK1.COMPARE

 : Perl          S" Perl" ;
 : Python        S" Python" ;
 : Ruby          S" Ruby" ;
 : JavaScript    S" JavaScript" ;
 : Java          S" Java" ;
 : Fortran       S" Fortran" ;
 : C             S" C" ;
 : C++           S" C++" ;
 : Basic         S" Basic" ;
 : Pascal        S" Pascal" ;
 : Lisp          S" Lisp" ;

: |   '   ,  ;  \ BF syntax sugar 

 CREATE POINTERS
   | Perl | Python | Ruby | JavaScript | Java | Fortran | C | C++ | Basic 
   HERE   | Pascal | Lisp 
  ( -- here ) CONSTANT PENULTIMATE

\ resolve a table entry to a name string
\ 10% faster using the text macro
 \ : NAME    S" @ EXECUTE" EVALUATE ; IMMEDIATE  
\ ** CHANGED TO USE PERFORM. Faster @ EXECUTE In Camel99 **

 \ swap adjacent table entries
 : SWP       DUP>R @  R@ CELL+ @  SWAP R@ CELL+ ! R> ! ;

 : PAIR      DUP PERFORM ROT CELL+ PERFORM ; \ two adjacent names

 : ARRANGE   DUP PAIR COMPARE 0> IF SWP EXIT THEN DROP ;

 \ bubbles from end of list towards the beginning.
 : BUBBLE   PENULTIMATE BEGIN 2DUP U> IF 2DROP EXIT THEN
            DUP ARRANGE [ 1 CELLS ] LITERAL - AGAIN ;

 : SORT     POINTERS BEGIN DUP PENULTIMATE U> IF DROP EXIT
            THEN DUP BUBBLE CELL+ AGAIN ;

 : E        DUP PERFORM TYPE SPACE CELL+ ;

 \ display current table state
 : SHOW     CR POINTERS E E E E E E E E E E E DROP CR ;
 : DEMO     SHOW SORT SHOW ;

\ DEMO
