\ insertion sort


NEEDS DUMP FROM DSK1.TOOLS
NEEDS RND  FROM DSK1.RANDOM
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VALUE FROM DSK1.VALUES

 1 CELLS CONSTANT CELL

: CELL-    S" 2-" EVALUATE ; IMMEDIATE \ Native 9900 instruction

: INSERT ( start end -- start )
         DUP @ >R
         BEGIN
           2DUP <
         WHILE
              R@ OVER CELL- @ <
         WHILE
              CELL- DUP @ OVER CELL+ !
         REPEAT
         THEN
         R> SWAP ! ;

: INSORT ( array len -- )
         1 DO
             DUP I CELLS + INSERT
         LOOP
         DROP ;

CREATE TEST 7 , 3 , 0 , 2 , 9 , 1 , 6 , 8 , 4 , 5 ,

TEST 10 INSORT
TEST 10 CELLS DUMP


\ ============ TESTING COMMANDS ======================
\ load the array with different kinds of mixed up data
HEX
2000 H !   \ reset the heap
: SET-SEED   994A SEED ;
: ?BREAK   KEY? 3 = ABORT" *BREAK*" ;

DECIMAL
1000 CONSTANT SIZE
SIZE CELLS  MALLOC CONSTANT Q[]

\ macro is a bit faster
: ]Q    S" CELLS Q[] + "  EVALUATE ;  IMMEDIATE

: ERASE   0 FILL ;


: CLEARIT  ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q ! LOOP ; \ 5:46.13
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !    LOOP ;
: RANDIT   ( -- ) SET-SEED SIZE  0 DO  256 RND I ]Q !   LOOP ;
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ;  \ only 2 different records
: TURTLES  ( -- )
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

: GO   Q[] SIZE INSORT ; \ 6:53 if already sorted

\ REAL IRON RESULTS
\             reversed    sorted     Random
\ SIZE=2000
\ SIZE=1000  352.33         1.03      179.01
\ SIZE=500    88.21        14.50       47.00
\ SIZE=200    14.18         0.25        7.30
\ SIZE=100     3.60         0.13        2.03
\ SIZE= 50     0.45         0.43        0.46
