\ QUICKSORT From Rossetta Code with test framework by B Fox

\ MODIFIED TO DO BYTE SORTING.  >>>work in progress<<<

INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MALLOC
INCLUDE DSK1.ELAPSE

\ macros for words used by Quicksort author
: -CELL   S" -2" EVALUATE ; IMMEDIATE
: CELL+   POSTPONE 2+ ; IMMEDIATE
: CELL-   POSTPONE 2- ; IMMEDIATE

: <=      S" 1+ <" EVALUATE ; IMMEDIATE

\ returns the value in the mid point of the array
: PIVOT ( l r -- PIVOT ) OVER - 2/ 1+ +  C@ ;

\ tried a few of these...
: EXCH   ( addr1 addr2 -- )
  S" 2DUP C@ SWAP C@  ROT C! SWAP C!" EVALUATE ; IMMEDIATE

: PARTITION ( l r -- l r r2 l2 )
  2DUP PIVOT >R ( r: pivot )
  2DUP
  BEGIN
    SWAP BEGIN  DUP C@  R@  < WHILE 1+ REPEAT
    SWAP BEGIN  R@ OVER C@  < WHILE 1- REPEAT
    2DUP <= IF 2DUP EXCH  >R 1+  R> 1-  THEN
    2DUP >
  UNTIL
  R> DROP ;

: QSORT ( l r -- )
  PARTITION  SWAP ROT
  2DUP < IF RECURSE ELSE 2DROP THEN
  2DUP < IF RECURSE ELSE 2DROP THEN ;

: QUICKSORT ( array len -- )
  DUP 2 < IF 2DROP EXIT THEN  1- OVER + QSORT ;


\ ============ TESTING COMMANDS ======================
HEX
2000 H !   \ reset the heap

DECIMAL
256 CONSTANT SIZE
SIZE MALLOC CONSTANT Q[]

\ macro is a bit faster
: ]Q    S" Q[] + "  EVALUATE ;  IMMEDIATE
: ERASE   0 FILL ;


\ load the array with different kinds of mixed up data
: CLEARIT  ( -- ) 0 ]Q SIZE ERASE ;     \ all the same data  8.16
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q C!      LOOP ; \ 4.4
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q C!      LOOP ;   \ 3.38
: RANDIT   ( -- ) SIZE  0 DO  256 RND I ]Q C!   LOOP ;     \ 8.08
: TWOIT    ( -- ) CLEARIT   99 45 ]Q C!  777 SIZE 2/ ]Q C! ; \ 2 different records 8.18
: TURTLES  ( -- ) \ 5.4
           SIZE 0
            DO
               I I CHAR+ ]Q C!   \ each 2 elements are reversed
               I CHAR+ I ]Q C!
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q C@ U. ?BREAK  LOOP ;

: GO
  CR ." Reversing array of " SIZE . ." integers"
  REVERSED
  CR ." Quick sorting ... "
   Q[] SIZE
   TICKER OFF
   QUICKSORT
   CR .ELAPSED
   CR ." Type .Q to see array " ; \ 4.4 SECONDS

\ REAL IRON RESULTS
\             reversed    sorted     Random
\ SIZE= 1000   4.41        3.88        7.78
\ SIZE= 500    2.08        1.81        3.60
\ SIZE= 200    0.85        0.75        1.30
\ SIZE= 100    0.41        0.36        0.63
\ SIZE= 50     0.20        0.18        0.30
