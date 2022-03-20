\ combsort.fth  taken from byte April 1991.  coded bfox Sept 94
\ PORTED to CAMEL99 Forth 2017

\ Approximately 10X faster than BUBBLE Sort except when list is
\ already sorted.

INCLUDE DSK1.TOOLS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.VALUES
INCLUDE DSK1.ARRAYS

0 VALUE GAP
VARIABLE SFLAG

DECIMAL
1000 VALUE  SIZE

SIZE 4 + ARRAY ]Q

: XCHG  ( adr1 adr2 n1 n2-- )
        S" OVER @ OVER @ SWAP ROT !  SWAP !" EVALUATE ; IMMEDIATE

\ usage:   X Y XCHG  \ moves contents from X->Y & Y->X
\ makes sort 6% faster than the Forth macro on 1000 item reversed sort
\  CODE XCHG   ( adr1 adr2 -- ) \ exchange values of 2 variables
\             *SP+  R0 MOV,    \ pop adr1 into R0
\             R0 ** W  MOV,    \ adr1 @  W  !
\           *TOS R0 ** MOV,    \ mem2me m move  adr2 to adr1
\              W  *TOS MOV,    \ move value adr1 to adr2
\                  TOS POP,
\                    NEXT,
\ ENDCODE

: BUBBLE ( n -- )  \ for comparison
    BEGIN
      SFLAG ON
      DUP 0
      DO
       I 1+ ]Q @   I ]Q @ <     \ test the values
       IF
          I 1+ ]Q   I ]Q  XCHG  \ exchange if needed
          SFLAG OFF
       THEN
      LOOP
      SFLAG @
   UNTIL
   DROP ;  \ 5:01.33 size=1000

\ testing harness
: ERASE   0 FILL ;

\ load the array with different kinds of mixed up data
: CLEARIT   ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data
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
: .Q  ( -- ) CR  SIZE  0 DO  I ]Q @ U. ?BREAK LOOP ;

\ GAP calculation makes the sort faster
\ 100/135 is the fastest GAP ratio I have found. (versus 10/13)
: /1.3 ( N -- N ) S" 100 135 */  1 MAX " EVALUATE ;  IMMEDIATE

: COMBSORT ( n -- )
    DUP 1+ TO GAP
    BEGIN
        GAP  /1.3  TO GAP                 \ additional line
        SFLAG ON
        DUP GAP -  0
        DO
         I GAP + ]Q @   I ]Q @ <     \ test the values
         IF
            I GAP + ]Q   I ]Q  XCHG  \ exchange if needed
            SFLAG OFF
         THEN
        LOOP
        SFLAG @  GAP 1 = AND     \ additional conditional
   UNTIL
   DROP ;
