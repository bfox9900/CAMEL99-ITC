\ combsort for the non-forth programmer

INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MALLOC
INCLUDE DSK1.ELAPSE

NEEDS VALUE FROM DSK1.VALUES

HEX
\ gratuitous variables for clarity
0 VALUE  GAP
VARIABLE SORTED

\ divide by 1.35 using Forth's scaling operator
\ found this ratio to be the fastest
: 1.35/  ( n -- n' ) 100 135 */ ; 

: XCHG  ( addr1 addr2 -- ) 2DUP @ SWAP @  ROT ! SWAP ! ; 

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
;

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

: CLEARIT  ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data 17.7
: REVERSED ( -- ) SIZE  0 DO  SIZE I -  I ]Q !      LOOP ; \ 18.0 seconds 
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !      LOOP ; \ 17.7
: RANDIT   ( -- ) SIZE  0 DO  256 RND I ]Q !   LOOP ;  \ 19.6
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ; \ 2 different records 17.7
: TURTLES  ( -- ) \ 18.0
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;


\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

: GO   Q[] SIZE COMBSORT ;  

