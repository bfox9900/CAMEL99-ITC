CR .( mergesort.fth from rosetta code )

INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MALLOC
INCLUDE DSK1.ELAPSE

DECIMAL 

\ camel99 forth translation harness 
: RDROP  POSTPONE R> POSTPONE DROP ; IMMEDIATE 
: <=     POSTPONE 1+  POSTPONE < ; IMMEDIATE 

1 CELLS CONSTANT CELL 

: MERGE-STEP ( right mid left -- right mid+ left+ )
  OVER @ OVER @ < IF
    OVER @ >R
    2DUP - OVER DUP CELL+ ROT MOVE
    R> OVER !
    >R CELL+ 2DUP = IF RDROP DUP ELSE R> THEN
  THEN CELL+ ;

: MERGE ( right mid left -- right left )
  DUP >R BEGIN 2DUP > WHILE MERGE-STEP REPEAT 2DROP R> ;

: MID ( l r -- mid ) OVER - 2/ CELL NEGATE AND + ;

: MERGESORT ( right left -- right left )
  2DUP CELL+ <= IF EXIT THEN
  SWAP 2DUP MID RECURSE ROT RECURSE MERGE ;
  
: MSORT ( addr len -- )  CELLS BOUNDS MERGESORT 2DROP ;

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
: .Q   ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK  LOOP ;

REVERSED

: GO   Q[] SIZE MSORT  ; \ 41 SECONDS 

