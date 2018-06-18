\ combsort.fth  taken from byte April 1991.  coded bfox Sept 94
\ PORTED to CAMEL99 Forth 2017

\ Approximately 10X faster than BUBBLE Sort except when list is 
\ already sorted.

HEX
83C0 CONSTANT SEED   \ RAM where TI has a number incrementing in main menu
1045 CONSTANT GEN#   \ GForth uses $10450405, we take the 1st 16 bits
: RNDW      ( -- n )   SEED @ GEN# UM* DROP 1+ DUP SEED ! ;
: RANDOMIZE ( n -- )   SEED ! ;
: RND       ( n -- n') RNDW ABS SWAP MOD ;

VARIABLE GAP
VARIABLE ITEMS
VARIABLE ADR
VARIABLE SFLAG
VARIABLE PASSES

DECIMAL
1000 CONSTANT SIZE

CREATE Q   SIZE CELLS CELL+ ALLOT

\ CODE []  ( n addr -- addr[n])  INLINE[ SWAP 2* + ] NEXT, END-CODE
\ : ]Q   ( n -- adr) Q INLINE[ SWAP 2* + ] ;

\ : ]Q  ( n -- adr) CELLS Q + ;   \ this is faster than using DOES>

 : ]Q    S" 2* Q + "  EVALUATE ;  IMMEDIATE

: ERASE   0 FILL ;

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

\ use this to print the array
: SEEIT   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK LOOP ;

\ : /1.3 ( N -- N ) 10 13 */  1 MAX ;

\ this macro makes the sort faster
\ 100/135 is the fastest GAP ratio I have found. (versus 10/13)
: /1.3 ( N -- N ) S" 100 135 */  1 MAX " EVALUATE ;  IMMEDIATE

: 1+!  ( n addr -- ) 1 SWAP +! ;

: XCHG  ( ADR ADR -- ) S"  OVER @  OVER @ SWAP ROT !  SWAP !" EVALUATE ; IMMEDIATE
: +GAP  ( n -- ) S" GAP @ +" EVALUATE ; IMMEDIATE


: COMBSORT ( N -- )
    DUP ITEMS ! GAP !
    0 PASSES !
    BEGIN
        GAP @  /1.3  GAP !                 \ additional line
        SFLAG ON
        ITEMS @  GAP @ -  0
        DO
           I +GAP ]Q @   I ]Q @  <
           IF
              I +GAP ]Q   I ]Q  XCHG
              SFLAG OFF
           THEN
        LOOP
\        PASSES 1+!
       SFLAG @  GAP @ 1 = AND     \ additional conditional
   UNTIL ;



: COMBIT
    CR ." COMB SORT! "
    SIZE COMBSORT
    CR ." Combsort complete in " PASSES ?  ."  PASSES" CR  .S ;


