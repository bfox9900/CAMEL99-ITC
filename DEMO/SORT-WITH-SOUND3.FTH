\ sorting demo with sound effects
\ Updated Jan 2022

NEEDS .S     FROM DSK1.TOOLS
NEEDS HZ     FROM DSK1.SOUND
NEEDS .S     FROM DSK1.TOOLS
NEEDS VCHAR  FROM DSK1.GRAFIX
NEEDS RND    FROM DSK1.RANDOM
NEEDS VALUE  FROM DSK1.VALUES
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS MARKER FROM DSK1.MARKER
NEEDS ARRAY  FROM DSK1.ARRAYS

MARKER /BARS

DECIMAL
32 CONSTANT SIZE  \ size of the data array

CREATE REFDATA
       3 , 11 , 10 ,  9 , 09 ,  3 , 10 , 10 ,
       4 ,  8 ,  6 ,  7 ,  8 ,  5 ,  2 , 12 ,
      01 ,  3 ,  8 , 02 , 03 , 08 , 05 , 07 ,
       7 ,  9 , 11 , 06 , 10 ,  4 , 11 , 04 ,

SIZE 2+ ARRAY ]Q

: ERASE   0 FILL ;

\ load the array with different kinds of mixed up data
: CLRDATA   ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data

\ : RANDDATA  ( -- ) REFDATA []Q  SIZE CELLS CMOVE ;
: [RND]Q   ( -- adr)
      32 RND ]Q
;

: RANDDATA  ( -- )
   97 SEED !   32 0 DO  23 RND 1+    I ]Q !   LOOP ;

: REVERSED
       32 0 DO   31 I -  I ]Q ! LOOP ;

: .DATA   SIZE 0 DO I ]Q @ . LOOP ;

\ Musical BAR graph
DECIMAL
      23 CONSTANT MAXH  \ max height of bars
     129 CONSTANT SQR
SQR  8 + CONSTANT SQR2
SQR2 8 + CONSTANT SQR3

: SHAPES
  S" FEFEFEFEFEFEFEFE" SQR CALLCHAR
  S" FEFEFEFEFEFEFEFE" SQR2 CALLCHAR
  S" FEFEFEFEFEFEFEFE" SQR3 CALLCHAR
;

: SET-COLORS
  SQR  SET#   16 15 COLOR  \ GRAY shadow on left side
  SQR2 SET#   13 15 COLOR  \ green
  SQR3 SET#    7 15 COLOR  \ red
;

: NOTE  ( value -- ) 15 * 350 + HZ  -8 DB ;

: /BAR  ( n -- ) 0 BL MAXH VCHAR ;  \ erase bar

: GRN.BAR ( col -- )
        DUP ]Q @ DUP>R NOTE
        R@ MAXH SWAP -  ( col height startrow )
        SQR2 R> VCHAR
;

: RED.BAR ( col -- )
        DUP ]Q @ DUP>R NOTE
        R@ MAXH SWAP -  ( col height startrow )
        SQR3 R> VCHAR
;

: WHT.BAR  ( col value -- )
        OVER /BAR MUTE
        DUP>R MAXH SWAP -  ( col height startrow )
        SQR R> VCHAR
;

: ]Q.DRAW ( ndx -- ) DUP ]Q @ WHT.BAR ; \ draw bar,  KILL sounds

: SHOWDATA
       32 0
       DO
          I ]Q.DRAW
       LOOP
       MUTE
;

: FINISH  32 0 DO  I GRN.BAR  LOOP  MUTE ;

VARIABLE GAP
VARIABLE ITEMS
VARIABLE SORTED
\ COMBSORT

\ 100/135 is the fastest GAP ratio I have found. (versus 10/13)
: /1.3 ( N -- N ) 100 135 */  1 MAX ;
: XCHG  ( ADR ADR -- ) OVER @  OVER @ SWAP ROT !  SWAP ! ;
: GAP+  ( n -- )       GAP @ + ;

: COMBSORT ( n -- )
    DUP GAP !
    BEGIN
        SORTED ON
        GAP @  /1.3  GAP !
        DUP GAP @ -  0
        DO
           I GAP+ RED.BAR  I GRN.BAR
           I GAP+ ]Q @   I ]Q @  <
           IF
              I GAP+ ]Q  I ]Q XCHG
              SORTED OFF
           THEN
           I  GAP+ ]Q.DRAW  I  ]Q.DRAW
        LOOP
        SORTED @  GAP @ 1 = AND
    UNTIL
    DROP
    MUTE
;

: BUBBLESORT  ( n -- )
    BEGIN
        SORTED ON
        DUP 1-  0
        DO
           I 1+ RED.BAR  I GRN.BAR

            I 1+ ]Q @  I ]Q @ <
           IF
               I 1+ ]Q   I ]Q XCHG
              SORTED OFF
           THEN
           I 1+ ]Q.DRAW  I ]Q.DRAW
        LOOP
       SORTED @
   UNTIL
   DROP
   MUTE
;

0 VALUE V

: INSERT ( n -- )
     BEGIN
        DUP 1+
     WHILE ( n>=0)
        DUP ]Q @  V >
      WHILE ( [n]Q > V)
        DUP 1+ RED.BAR  DUP GRN.BAR
        DUP 1+ ]Q  OVER ]Q XCHG
        DUP 1+ ]Q.DRAW  DUP ]Q.DRAW
        1-  ( n=n-1)
     REPEAT THEN
     DROP
;

: INSERTIONSORT ( n --  )
   1
   DO
     I ]Q @ TO V
     I 1- INSERT
   LOOP
   MUTE  ;

\ scripting tools
: CLEARLN ( col row --)  BL 32 HCHAR ;
: TITLE:  0 23 2DUP CLEARLN AT-XY    ;
: TIME:   0 1 AT-XY ;
: WAIT-KEY  BEGIN KEY? UNTIL ;

\ DEMO scripts
: COMB
     REVERSED
     PAGE TITLE: ." Comb Sort"
     SHOWDATA
     TICKER OFF
     SIZE COMBSORT
     FINISH
     TIME: .ELAPSED
;

: BUBBLE
     REVERSED
     PAGE TITLE: ." Bubble Sort"
     SHOWDATA
     TICKER OFF
     SIZE BUBBLESORT
     FINISH
     TIME: .ELAPSED
;

: INSERTION
     REVERSED
     PAGE TITLE: ." Insertion Sort"
     SHOWDATA
     TICKER OFF
     SIZE INSERTIONSORT
     FINISH
     TIME: .ELAPSED
;

: RUN
      GRAPHICS
      SHAPES SET-COLORS
      3 10 AT-XY ." Three Sorts with Animation"

      5 12 AT-XY ."      Camel99 Forth"

      5 14 AT-XY ."    For the TI-99/4a"
      3000 MS
      11 SCREEN  BUBBLE  1500 MS
       9 SCREEN  COMB    1500 MS
       8 SCREEN  INSERTION
      WAIT-KEY ;

: COLD   INITS  RUN  BYE ;

LOCK
INCLUDE DSK1.SAVESYS
' COLD SAVESYS DSK2.ALLSORTS
