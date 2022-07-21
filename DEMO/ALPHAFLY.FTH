\ alpha intelligence demonstration as fly  8Jul2022  Brian Fox

\ Alpha intelligence algorithm:
\ BEGIN
\   Choose random direction
\   BEGIN
\    WHILE ClearAhead?
\      MoveForward
\   REPEAT
\ AGAIN

\ This version has a word called CRAZY which adds a 9% chance of
\ The fly picking a random direction while it's travelling.
\ This seems to make it harder to trap the fly.

INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.UDOTR
INCLUDE DSK1.DATABYTE
INCLUDE DSK1.MATRIX

: VECT+        ( x y dx dy -- x' y' ) ROT +  -ROT + SWAP ;

\ ==================================
\ character patterns
HEX
CREATE REDBRICK  DATA 00FE,FEFE,FEFE,FEFE

\ ==================================================
\ straight direction FLY shapes
CREATE FLYUP     DATA 0028,1038,7CD6,C600
CREATE FLYDWN    DATA 0000,C6D6,7C38,1028
CREATE FLYLEFT   DATA 000C,1CB0,78B0,1C0C
CREATE FLYRGHT   DATA 0030,380D,1E0D,3830
\ angled direction FLY shapes
CREATE FLYNW     DATA 0020,6F1F,3834,3030
CREATE FLYNE     DATA 0004,F6F8,1C2C,0C0C
CREATE FLYSE     DATA 0C0C,2C1C,F8F6,0400
CREATE FLYSW     DATA 3030,3438,1F6F,2000

3 3 MATRIX: []FACES

: >COORDS  ( vector -- col row)  1 1 VECT+ ; \ bias for neg. numbers
: ]FACE    ( vector -- addr) >COORDS  []FACES ;

\ fill matrix with character shapes at compile time
: FILL-MATRIX ( -- )
\            dx  dy
    FLYUP     0 -1 ]FACE !
    FLYDWN    0  1 ]FACE !
    FLYLEFT  -1  0 ]FACE !
    FLYRGHT   1  0 ]FACE !
    FLYSE     1  1 ]FACE !
    FLYNW    -1 -1 ]FACE !
    FLYNE     1 -1 ]FACE !
    FLYSW    -1  1 ]FACE !
;

FILL-MATRIX

\ named chars
DECIMAL
160 CONSTANT THEFLY
168 CONSTANT BRICK

\ double variable hold Y and X
CREATE VECTOR 0 , 0 ,

: DIRECTION ( vector -- ) 2DUP VECTOR 2! ]FACE @ THEFLY CHARDEF ;

\ define chars
 REDBRICK  BRICK CHARDEF   BRICK SET#  7 15 COLOR

: CLIP   ( n low hi -- n') ROT MIN MAX ;

: RNDX   ( -- x)  23 RND 2 22 CLIP ;
: RNDY   ( -- y)  33 RND 2 30 CLIP ;

: .BORDER   ( -- )
  \ col row
     0   1 BRICK 32 HCHAR
     0  23 BRICK 32 HCHAR
     0   1 BRICK 23 VCHAR
    31   1 BRICK 23 VCHAR ;

: RND.WALLS
    10 RND 4 +  0 DO  RNDY RNDX BRICK  10 RND 1+ VCHAR  LOOP
    10 RND 4 +  0 DO  RNDY RNDX BRICK  10 RND 1+ HCHAR  LOOP
;

\ ==================================
CREATE MY-XY  RNDY , RNDX ,    \ independant cursor for alpha guy

: RNDV     ( -- -1 0 1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;

: NEW-VECTORS  ( -- X Y)      \ prevents a (0,0) vector condition
               RNDV DUP 0=    \ If 1st # is 0
               IF    NON-0    \ wait for a non-zero 2nd #
               ELSE  RNDV
               THEN ;

: CHANGE-DIR   ( -- ) NEW-VECTORS  DIRECTION ;
: VECTOR@      ( --  dx dy)  VECTOR 2@ ;

\ VDP memory screen control
: GETXY     ( -- x y) MY-XY 2@ ;
: PUT-CHAR  ( c -- ) GETXY >VPOS VC! ;
: CLRLN     ( col row -- ) AT-XY  VPOS C/L@  BL VFILL ;
: ERASE-FLY ( -- )   BL PUT-CHAR ;
: .FLY      ( -- )   THEFLY PUT-CHAR ;

: READ-CHAR ( y x -- c) >VPOS VC@ ;  \ read char without moving cursor
: NEXT-POS  ( -- y x ) GETXY VECTOR@ VECT+ ;
: CRAZY     ( -- )  100 RND 2 < IF  CHANGE-DIR  THEN ;

VARIABLE SPEED
: MOVE-FLY  ( -- )
          ERASE-FLY
          NEXT-POS MY-XY 2!
          .FLY  CRAZY
          SPEED @ MS    \ speed delay
;

DECIMAL
VARIABLE TRYS

: .BRAIN     ( -- )
  0 0 CLRLN
 ." Vector"  VECTOR 2@  2 .R ." ," 2 .R  SPACE ." Trys " TRYS @ 2 .R
;

: COLOR-FLY    ( -- ) THEFLY SET#  4 1 COLOR  ;
: BLACK-FLY    ( -- ) THEFLY SET#  2 1 COLOR  ;

: LOOK-AHEAD   ( -- c) NEXT-POS READ-CHAR ;

: CLEAR-AHEAD? ( -- ?) LOOK-AHEAD  BL = ;
: ?TRAPPED    ( n -- ) 35 > ABORT" Fly is trapped!" ;

: ALPHA-THINK  ( -- )
            TRYS OFF                   \ reset the trys counter
            BEGIN
               COLOR-FLY               \ change color while thinking
               CHANGE-DIR              \ get new direction
               1 TRYS +!               \ count the try
               TRYS @ ?TRAPPED
               .BRAIN                  \ report to screen
               200 MS
               CLEAR-AHEAD?
            UNTIL
            BLACK-FLY
;

HEX
: NO-TIMEOUT   83D6 ON ;

DECIMAL
: TITLE-PAGE ( -- )
           16 SCREEN  NO-TIMEOUT
           PAGE 4 10 AT-XY ." Fly Intelligence Demo"
           FILL-MATRIX
           REDBRICK  BRICK CHARDEF
           BRICK SET#  7 15 COLOR
;

: EMPTY-XY ( -- y x) \ find empty place on the screen
        BEGIN
          RNDY RNDX 2DUP
          READ-CHAR BL <>
        WHILE
          2DROP
        REPEAT ;

: SAFE.FLY ( -- )  EMPTY-XY MY-XY 2!  .FLY ;

: NEW-MAZE      PAGE  .BORDER RND.WALLS  BLACK-FLY SAFE.FLY ;

: RUN      ( -- )
       TITLE-PAGE 1000 MS
       40 SPEED !
       NEW-MAZE
       BEGIN
         ALPHA-THINK
         BEGIN
           ?BREAK
           CLEAR-AHEAD?
         WHILE
           MOVE-FLY
         REPEAT
         KEY? IF NEW-MAZE THEN
      AGAIN ;
