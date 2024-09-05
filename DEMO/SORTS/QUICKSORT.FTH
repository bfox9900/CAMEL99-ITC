\ QUICKSORT From Rossetta Code with test framework by B Fox

INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MALLOC
INCLUDE DSK1.ELAPSE

\ macros for words used by Quicksort author
: -CELL   S" -2" EVALUATE ; IMMEDIATE
: CELL+   POSTPONE 2+ ; IMMEDIATE
: CELL-   POSTPONE 2- ; IMMEDIATE

: <=      S" 1+ <" EVALUATE ;  IMMEDIATE

: MID ( l r -- mid ) OVER - 2/ -CELL AND + ;

\ tried a few of these...
\ : EXCH ( addr1 addr2 -- ) DUP @ >R OVER @ SWAP ! R> SWAP ! ;
\ : EXCH ( addr1 addr2 -- ) OVER @ OVER @ SWAP ROT ! SWAP ! ;
: EXCH   ( addr1 addr2 -- ) 2DUP @ SWAP @  ROT ! SWAP ! ;

: PARTITION ( l r -- l r r2 l2 )
  2DUP MID @ >R ( r: pivot )
  2DUP
  BEGIN
    SWAP BEGIN  DUP @  R@  < WHILE CELL+ REPEAT
    SWAP BEGIN  R@ OVER @  < WHILE CELL- REPEAT
    2DUP <= IF 2DUP EXCH  >R CELL+ R> CELL-  THEN
    2DUP >
  UNTIL
  R> DROP ;

: QSORT ( l r -- )
  PARTITION  SWAP ROT
  2DUP < IF RECURSE ELSE 2DROP THEN
  2DUP < IF RECURSE ELSE 2DROP THEN ; 

: QUICKSORT ( array len -- )
  DUP 2 < IF 2DROP EXIT THEN  1- CELLS OVER + QSORT ;


\ ============ TESTING COMMANDS ======================
HEX
2000 H !   \ reset the heap 

DECIMAL
1000 CONSTANT SIZE
SIZE CELLS  MALLOC CONSTANT Q[]

\ macro is a bit faster
: ]Q    S" CELLS Q[] + "  EVALUATE ;  IMMEDIATE
: ERASE   0 FILL ;


\ load the array with different kinds of mixed up data
: CLEARIT  ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data  8.16
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q !      LOOP ; \ 4.4 
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !      LOOP ;   \ 3.38 
: RANDIT   ( -- ) SIZE  0 DO  256 RND I ]Q !   LOOP ;     \ 8.08
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ; \ 2 different records 8.18
: TURTLES  ( -- ) \ 5.4 
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

REVERSED
: GO   Q[] SIZE QUICKSORT  ; \ 4.4 SECONDS 


