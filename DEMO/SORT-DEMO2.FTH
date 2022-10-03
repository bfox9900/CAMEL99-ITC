\ sorting demo with sound effects, with Quick-Sort   May 6 2022 Brian Fox

NEEDS .S     FROM DSK1.TOOLS
NEEDS HZ     FROM DSK1.SOUND
NEEDS .S     FROM DSK1.TOOLS
NEEDS VCHAR  FROM DSK1.GRAFIX
NEEDS RND    FROM DSK1.RANDOM
NEEDS VALUE  FROM DSK1.VALUES
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS ARRAYS FROM DSK1.ARRAYS
NEEDS MARKER FROM DSK1.MARKER

MARKER /BARS

DECIMAL
32 CONSTANT SIZE  \ size of the data array
SIZE ARRAY ]Q

CREATE REFDATA
      22 ,  11 , 10 ,  3 ,  9 ,  21 ,  2 , 18 ,
       4 ,  13 ,  6 , 17 ,  8 ,  5 ,  16 , 12 ,
      01 ,  19 ,  8 , 02 , 03 , 23 ,  15 , 07 ,
       7 ,   9 , 11 , 06 , 10 ,  4 ,   1 , 14 ,

\ load the array with different kinds of mixed up data
: LOAD-DATA  ( -- ) REFDATA  0 ]Q  SIZE CELLS CMOVE ;

\ Musical BAR graph
DECIMAL
      23 CONSTANT MAXH  \ max height of bars
     129 CONSTANT SQR
SQR  8 + CONSTANT SQR2
SQR2 8 + CONSTANT SQR3

S" FEFEFEFEFEFEFEFE" SQR CALLCHAR
S" FEFEFEFEFEFEFEFE" SQR2 CALLCHAR
S" FEFEFEFEFEFEFEFE" SQR3 CALLCHAR

SQR  SET#   16 2 COLOR  \ black shadow on left side
SQR2 SET#   13 2 COLOR  \ green
SQR3 SET#    7 2 COLOR  \ red

: NOTE  ( n -- ) 20 * 200 + HZ ;
: /BAR  ( n -- ) 0 BL MAXH VCHAR ;

: DELAY   200 TICKS ;

: .GRNBAR ( col -- )
        DUP ]Q @ DUP>R MAXH SWAP -  ( col height startrow )
        SQR2 R> VCHAR  DELAY ;

: .REDBAR ( col -- )
        DUP ]Q @ DUP>R MAXH SWAP -  ( col height startrow )
        SQR3 R> VCHAR DELAY ;

: .BAR  ( col value -- )
        OVER /BAR
        DUP>R MAXH SWAP -  ( col height startrow )
        R@ NOTE
        SQR R> VCHAR ;

: ]Q.DRAW ( ndx -- ) DUP ]Q @ .BAR ; \ draw bar

: SOUND-ON   GEN1  15000 HZ  -6 DB ;

: SHOWDATA   SOUND-ON  32 0 DO  I ]Q.DRAW   LOOP MUTE ;

: FINISH
     32 0 DO
          I .GRNBAR
          I ]Q @ NOTE
      LOOP
      MUTE ;

\ scripting tools
: CLEARLN ( col row --)  BL 32 HCHAR ;
: TITLE:  0 23 2DUP CLEARLN  AT-XY ;
: TIME:   0 1 AT-XY ;
: WAIT-KEY  BEGIN KEY? UNTIL ;

\ ===========================================================
\ COMBSORT
VARIABLE GAP
VARIABLE ITEMS
VARIABLE ADR
VARIABLE SORTED

\ 100/135 is the fastest GAP ratio I have found. (versus 10/13)
: /1.3 ( N -- N ) 100 135 */  1 MAX ;
: XCHG  ( ADR ADR -- ) OVER @  OVER @ SWAP ROT !  SWAP ! ;
: +GAP  ( n -- )       GAP @ + ;
: COMBSORT ( n -- )
    SOUND-ON
    DUP GAP !
    BEGIN
        SORTED ON
        GAP @  /1.3  GAP !
        DUP GAP @ -  0
        DO
           I +GAP .REDBAR  I .GRNBAR
           I +GAP ]Q   I ]Q
           OVER @ OVER @ <
           IF
              XCHG
              SORTED OFF
           ELSE
              2DROP
           THEN
           I  +GAP ]Q.DRAW  I  ]Q.DRAW
        LOOP
        SORTED @  GAP @ 1 = AND
    UNTIL
    DROP
;
\ ===========================================================
: BUBBLESORT  ( n -- )
    SOUND-ON
    BEGIN
        SORTED ON
        DUP 1-  0
        DO
           I 1+ .REDBAR  I .GRNBAR
           I 1+ ]Q   I ]Q
           OVER @ OVER @ <
           IF
              XCHG
              SORTED OFF
          ELSE
              2DROP
          THEN
          I 1+ ]Q.DRAW  I ]Q.DRAW
        LOOP
       SORTED @
   UNTIL
   DROP
;

\ ===========================================================
0 VALUE V

: INSERT ( n -- )
     BEGIN
        DUP 1+  WHILE ( n>=0)
        DUP ]Q @  V > WHILE ( [n]Q > V)
        DUP 1+ .REDBAR  DUP .GRNBAR
        DUP 1+ ]Q  OVER ]Q XCHG
        DUP 1+ ]Q.DRAW  DUP ]Q.DRAW
        1-  ( n=n-1)
     REPEAT
     THEN
     DROP
;

: INSERTIONSORT ( n --  )
   SOUND-ON
   1
   DO
     I ]Q @ TO V
     I 1- INSERT
   LOOP
;

\ =============================================================
\ Quick Sort from Rossetta Code
\ macros for words used by Quicksort author
: -CELL   S" -2" EVALUATE ; IMMEDIATE
: CELL+   S" 2+" EVALUATE ; IMMEDIATE
: CELL-   S" 2-" EVALUATE ; IMMEDIATE
: <=      S" 1+ <" EVALUATE ;  IMMEDIATE
: MID ( l r -- mid ) OVER - 2/ -CELL AND + ;

: EXCH    ( adr1 adr2 -- )  OVER @ OVER @ SWAP ROT ! SWAP ! ;

\ quick sort uses addresses not indices so we need to translate
: >COL    ( addr --  n)  0 ]Q - 2/ ;

: .GRN  ( addr -- addr) DUP >COL .GRNBAR ;
: .RED  ( addr -- addr) DUP >COL .REDBAR ;

: .2BARS    ( addr1 addr2 -- addr1 addr2 )
       OVER >COL ]Q.DRAW   OVER >COL ]Q.DRAW ;

DECIMAL
: PARTITION ( l r -- l r r2 l2 )
  .GRN
  2DUP MID .RED @ >R ( r: pivot )
  2DUP
  BEGIN
    SWAP  BEGIN  DUP @  R@  < WHILE CELL+  REPEAT
    SWAP  BEGIN  R@ OVER @  < WHILE CELL-  REPEAT
    2DUP <= IF 2DUP EXCH .2BARS >R CELL+ R> CELL-  THEN
    .2BARS
    2DUP >
  UNTIL
  R> DROP ;

: (QSORT) ( l r -- )
  PARTITION  SWAP ROT
    2DUP < IF RECURSE  ELSE 2DROP THEN
    2DUP < IF RECURSE  ELSE 2DROP THEN ;

: QSORT ( array len -- )
  SOUND-ON
  DUP 2 < IF 2DROP EXIT THEN  1- CELLS OVER + (QSORT)
;

\ ===========================================================
\ ===========================================================

\ DEMO scripts
: COMB
     LOAD-DATA
     PAGE SHOWDATA
     TITLE: ." Comb Sort"
     TICKER OFF
     SIZE COMBSORT FINISH
     TIME: .ELAPSED
;

: BUBBLE
     LOAD-DATA
     PAGE SHOWDATA
     TITLE: ." Bubble Sort"
     TICKER OFF
     SIZE BUBBLESORT FINISH
     TIME: .ELAPSED
;

: INSERTION
     LOAD-DATA
     PAGE SHOWDATA
     TITLE: ." Insertion Sort"
     TICKER OFF
     SIZE INSERTIONSORT FINISH
     TIME: .ELAPSED
;

: QUICK-SORT
     LOAD-DATA
     PAGE SHOWDATA
     TITLE: ." Quick Sort"
     TICKER OFF
     0 ]Q SIZE QSORT FINISH
     TIME: .ELAPSED
;

: RUN
      PAGE
      11 SCREEN
      BUBBLE  1500 MS
      COMB    1500 MS
      INSERTION 1500 MS
      QUICK-SORT
      WAIT-KEY ;
