\ insertion sort


INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MALLOC
INCLUDE DSK1.ELAPSE

 1 CELLS CONSTANT CELL

: CELL-    S" 2-" EVALUATE ; IMMEDIATE \ Native 9900 instruction

: INSERT ( start end -- start )
         DUP @ >R
         BEGIN
           2DUP <
         WHILE
              R@ OVER CELL- @ <
         WHILE
              CELL-
              DUP @ OVER CELL+ !
         REPEAT
         THEN
         R> SWAP ! ;

: INSERTIONSORT ( array len -- )
         1 DO
             DUP I CELLS + INSERT
         LOOP
         DROP ;

\ ============ TESTING COMMANDS ======================
\ load the array with different kinds of mixed up data
HEX
2000 H !   \ reset the heap

DECIMAL
1000 CONSTANT SIZE
SIZE CELLS  MALLOC CONSTANT Q[]

\ macro is a bit faster
: ]Q    S" CELLS Q[] + "  EVALUATE ;  IMMEDIATE

: ERASE   0 FILL ;


: CLEARIT  ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q ! LOOP ; \ 5:46.13
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !    LOOP ;
: RANDIT   ( -- ) SIZE  0 DO  256 RND I ]Q !   LOOP ;
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ;  \ only 2 different records
: TURTLES  ( -- )
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

: GO   Q[] SIZE INSERTIONSORT ; \ 6:53 if already sorted
