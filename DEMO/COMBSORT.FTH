\ combsort.fth  taken from byte April 1991.  coded bfox Sept 94
\ PORTED to CAMEL99 Forth 2017, Updated June 2024 

\ Combsort is 27X faster than BUBBLE Sort on 1000 out of order integers
\ Bubble Sort is faster when list is already sorted

\ camel forth harness ...
INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.VALUES


\ turboforth harness ...
\ : ?TERMINAL   KEY? 2 = ;
\ : ON   TRUE SWAP ! ;
\ : OFF  false swap ! ;
\ : DUP>R   COMPILE DUP COMPILE >R  ; IMMEDIATE 
\ ------------------------------

\ FbForth harness ... 
\ : R@   COMPILE R ; IMMEDIATE 
\ : ON  -1 SWAP ! ;
\ : OFF  0 SWAP ! ;
\ : DUP>R   COMPILE DUP  COMPILE >R ; IMMEDIATE 
\ : VARIABLE   0 VARIABLE ;
\ : VALUE       CONSTANT ;
\ : TO   ?COMP  [COMPILE] '  COMPILE !  ;  IMMEDIATE 
\ : CREATE  0 VARIABLE ;
\ : CELLS  STATE @ IF COMPILE 2* ELSE 2* ENDIF ; IMMEDIATE 
\ : CELL+  STATE @ IF COMPILE 2+ ELSE 2+ ENDIF ; IMMEDIATE 

\ Camel Forth code begins ....
VARIABLE SORTED 

\ SIZE can be changed to adjust the array size 
DECIMAL
1000 VALUE  SIZE

CREATE Q[]  SIZE 4 +  CELLS  ALLOT 

: ]Q   ( n -- addr ) CELLS Q[] + ;

\ testing harness
: ERASE   0 FILL ;

\ load the array with different kinds of mixed up data
: CLEARIT   ( -- ) Q[] SIZE CELLS ERASE ;     \ all the same data
: REVERSED  ( -- ) SIZE  0 DO  SIZE I -  I ]Q !  LOOP ;
: ASCEND    ( -- ) SIZE  0 DO       I    I ]Q !  LOOP ;
: RANDIT    ( -- ) SIZE  0 DO  SIZE RND  I ]Q !  LOOP ;
: TWOIT     ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ;
: TURTLES   ( -- )
       SIZE 0
       DO
          I     I 1+ ]Q !   \ each 2 elements are reversed
          I 1+     I ]Q !
      2 +LOOP ;

\ use this to print the array
: ?BREAK   ?TERMINAL ABORT" *Break*"  ;

: .Q  ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK LOOP ;


\ =========================== SORTING ==============================
: XCHG  ( addr1 addr2 -- ) 2DUP @ SWAP @  ROT ! SWAP ! ; 

\ === ALTERNATES FOR XCHG === 
\ : XCHG  ( adr1 adr2 -- ) \ my 1st version 
\        S" OVER @ OVER @ SWAP ROT !  SWAP !" EVALUATE ; IMMEDIATE

\ : EXCHANGE ( A1 A2 -- ) \ Leo Wong
\        S" 2DUP 2>R  @ SWAP @  R> !  R> ! "  EVALUATE ; IMMEDIATE

\ =========================

DECIMAL 
0 VALUE  GAP

\ divide by 1.35 using Forth's scaling operator
\ found this ratio to be the fastest
: 1.35/  ( n -- n' ) 100 135 */ ;

: COMBSORT ( addr n -- )
    DUP>R  TO GAP                    \ save n on Rstack and in GAP 
    BEGIN
      GAP 1.35/  TO GAP              \ re-compute the gap
      SORTED ON
      R@ ( -- n) GAP -  0           \ n-gap is loop limit
      DO ( -- addr )
         DUP I CELLS +  DUP GAP CELLS +  ( -- addr1 addr2 )
         OVER @ OVER @ >             \ compare the contents of cells 
         IF
            XCHG                     \ Exchange the data in the cells
            SORTED OFF               \ flag we are not sorted
         ELSE 
           2DROP 
         THEN
      LOOP
      SORTED @  GAP 0=  AND          \ test for complete
   UNTIL
   R> 2DROP
;                                    \ 13 seconds 

: BUBBLE ( addr n -- ) \ for comparison
    >R
    BEGIN
      SORTED ON
      R@ 0
      DO
         DUP I CELLS +  DUP CELL+    \ addresses for adjacent cells 
         OVER @ OVER @ >             \ compare the contents of cells 
         IF
           XCHG 
           SORTED OFF
         ELSE 
           2DROP    
         THEN
      LOOP
      SORTED @
   UNTIL
   R> 2DROP ;  \ 5:52.11  size=1000  :-) S

\ Usage examples: 
\ REVERSED  Q[] SIZE COMBSORT 
\ TURTLES   Q[] SIZE COMBSORT 
\ CLEARIT   Q[] SIZE BUBBLE  

\ Camel Forth timed tests 
: COMBTEST 
   CR ." Combsort 1000 integers ..."
   REVERSED  TICKER OFF  
   Q[] SIZE COMBSORT  
   CR .ELAPSED 
;

: BUBBLETEST 
   CR ." Bubble sort 1000 integers ..."
   REVERSED  TICKER OFF 
   Q[] SIZE  BUBBLE
   CR .ELAPSED
;

