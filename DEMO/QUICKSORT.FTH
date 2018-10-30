\ QUICKSORT From Rossetta Code with test framework by B Fox
INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.ELAPSE

HEX
VARIABLE GAP
VARIABLE ITEMS
VARIABLE ADR
VARIABLE SFLAG
VARIABLE PASSES

DECIMAL
2000 CONSTANT SIZE

CREATE Q   SIZE CELLS CELL+ ALLOT

\ CODE []  ( n addr -- addr[n])  INLINE[ SWAP 2* + ] NEXT, END-CODE
\ : ]Q   ( n -- adr) Q INLINE[ SWAP 2* + ] ;

\ : ]Q  ( n -- adr) CELLS Q + ;   \ this is faster than using DOES>

 : ]Q    S" 2* Q + "  EVALUATE ;  IMMEDIATE

: ERASE   0 FILL ;

\ macros for words used by Quicksort author
: -CELL   S" -2" EVALUATE ; IMMEDIATE
: CELL+   S" 2+" EVALUATE ; IMMEDIATE
: CELL-   S" 2-" EVALUATE ; IMMEDIATE

: <=      S" 1+ <" EVALUATE ;  IMMEDIATE

: MID ( l r -- mid ) OVER - 2/ -CELL AND + ;

\ : XCHG ( addr1 addr2 -- ) DUP @ >R OVER @ SWAP ! R> SWAP ! ;
: EXCH        OVER @ OVER @ SWAP ROT ! SWAP ! ;

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

: SORT ( array len -- )
  DUP 2 < IF 2DROP EXIT THEN  1- CELLS OVER + QSORT ;

: QUICKSORT
            CR ." QUICKSORT!"
            TICKER OFF  
            Q SIZE SORT
            .ELAPSED 
            CR SIZE . ." integers" ;

\ ============ TESTING COMMANDS ======================
\ load the array with different kinds of mixed up data
: CLEARIT  ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q !      LOOP ;
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !      LOOP ;
: RANDIT   ( -- ) SIZE  0 DO  256 RND I ]Q !   LOOP ;
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ;  \ only 2 different records
: TURTLES  ( -- )
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: SEEIT   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;
\ ===================================================
