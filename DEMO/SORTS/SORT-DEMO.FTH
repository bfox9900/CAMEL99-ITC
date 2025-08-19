\ sorting demo with sound effects
\ Updated Jan 2022
\ Updated Jun 2025 to use TI LOGO colour names

NEEDS .S     FROM DSK1.TOOLS
NEEDS HZ     FROM DSK1.SOUND
NEEDS .S     FROM DSK1.TOOLS
NEEDS VCHAR  FROM DSK1.GRAFIX
NEEDS RND    FROM DSK1.RANDOM
NEEDS VALUE  FROM DSK1.VALUES
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS MARKER FROM DSK1.MARKER
NEEDS ARRAY  FROM DSK1.ARRAYS
NEEDS RED    FROM DSK1.COLORS


MARKER /BARS

DECIMAL
24 CONSTANT SIZE  \ size of the data array

SIZE ARRAY ]Q

: ERASE   0 FILL ;

\ load the array with different kinds of mixed up data
: CLRDATA   ( -- ) 0 ]Q SIZE CELLS ERASE ;     \ all the same data

: REVERSED  ( -- )
       SIZE 0 DO   SIZE 1-  I -  I ]Q ! LOOP ;

: .DATA   SIZE 0 DO I ]Q @ . LOOP ;

\ Musical BAR graph
DECIMAL
      23 CONSTANT MAXH  \ max height of bars
     129 CONSTANT SQR
SQR  8 + CONSTANT SQR2
SQR2 8 + CONSTANT SQR3

: SHAPES
  S" FEFEFEFEFEFEFEFE"
  2DUP SQR CALLCHAR
  2DUP SQR2 CALLCHAR
  SQR3 CALLCHAR
;

: SET-COLORS
  SQR  SET#   WHITE GRAY COLOR  \ GRAY shadow on left side
  SQR2 SET#   LIME  GRAY COLOR  \ green
  SQR3 SET#   RED   GRAY COLOR  \ red
;

: NOTE  ( value -- ) 4 LSHIFT 400 + HZ  -6 DB  ;

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
        OVER /BAR
        DUP>R MAXH SWAP -  ( col height startrow )
        SQR R> VCHAR
        MUTE
;

: ]Q.DRAW ( ndx -- ) DUP ]Q @ WHT.BAR ; \ draw bar,  KILL sounds

: SHOWDATA
       SIZE 0
       DO
          I ]Q.DRAW
       LOOP
       MUTE
;

: FINISH  SIZE 0 DO  I GRN.BAR  LOOP  MUTE ;

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
: CLEARLN ( col row --)  BL C/L@  HCHAR ;
: TITLE:  0 23 CLEARLN  10 23 AT-XY ;
: TIME:   0 0 AT-XY ;
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
      SHAPES
      SET-COLORS
      3 10 AT-XY ." Three Sorts with Animation"

      5 12 AT-XY ."      Camel99 Forth"

      5 14 AT-XY ."    For the TI-99/4a"
      2700 MS
      11 SCREEN  BUBBLE  1500 MS
       9 SCREEN  COMB    1500 MS
       8 SCREEN  INSERTION
      WAIT-KEY ;

: COLD   WARM  RUN  BYE ;

 LOCK
 INCLUDE DSK1.SAVESYS
 ' COLD SAVESYS DSK3.SORTDEMO
