\ TEST lexicon for sorting algorythms

NEEDS DUMP FROM DSK1.TOOLS
NEEDS RND  FROM DSK1.RANDOM
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VALUE FROM DSK1.VALUES

HEX
2000 H !   \ reset the heap

: SET-SEED   994A SEED ;
\ : ?BREAK   KEY? 3 = ABORT" *BREAK*" ; for TTY version

DECIMAL
1000 CONSTANT SIZE

SIZE CELLS  MALLOC CONSTANT Q[]

: ]Q    CELLS Q[] + ;

: ERASE   0 FILL ;
: CLEARIT   ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data 17.7

\ load the array with different kinds of mixed up data
: REVERSED  ( -- ) SIZE  0 DO  SIZE I -  I ]Q ! LOOP ; \ 17.11 seconds
: ASCENDING ( -- ) SIZE  0 DO     I  I ]Q !     LOOP ;    \ 16.3
: RANDIT    ( -- ) SET-SEED  SIZE  0 DO  256 RND I ]Q !   LOOP ;  \ 18.11
\ 2 different records 16.3
: TWOIT    ( -- ) CLEARIT   99 45 ]Q !  777 SIZE 2/ ]Q ! ;
: TURTLES  ( -- ) \ 16.6
           SIZE 0
            DO
               I I CHAR+ ]Q !   \ each 2 elements are reversed
               I CHAR+ I ]Q !
            2 +LOOP ;

\ use this to print the array (use FNCT 4 to break out (ALT 4 on PC)
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

: TEST ( -- )
      Q[] SIZE 1-  BOUNDS
      DO
         I @  I CELL+ @ > ABORT" Not sorted"
      LOOP
      ." Sorted in ascending order"
;
