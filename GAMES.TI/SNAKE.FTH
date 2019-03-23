\ snake  a simple game in Forth ported to CAMEL99 Forth
\ source https://skilldrick.github.io/easyforth/#snake

INCLUDE DSK1.RANDOM

HEX
83C0 CONSTANT SEED   \ RAM where TI has a number incrementing in main menu
1045 CONSTANT GEN#   \ GForth uses $10450405, we take the 1st 16 bits

: RNDW      ( -- n )   SEED @ GEN# UM* DROP 1+ DUP SEED ! ;
: RANDOMIZE ( n -- )   SEED ! ;
: RND       ( n -- n') RNDW ABS SWAP MOD ;

DECIMAL
VARIABLE SNAKE-X-HEAD  500 CELLS ALLOT
VARIABLE SNAKE-Y-HEAD  500 CELLS ALLOT
VARIABLE APPLE-X
VARIABLE APPLE-Y

0 CONSTANT LEFT
1 CONSTANT UP
2 CONSTANT RIGHT
3 CONSTANT DOWN

HEX
CREATE MAC   0006 , 093C , 7E7E , 7E3C ,
CREATE CLAY  007E , 6A56 , 6A56 , 7E00 ,
CREATE VIPER 3C5E , EBF7 , EBDD , 7E3C ,

DECIMAL
128 CONSTANT APPLE
42  CONSTANT SNAKE
30  CONSTANT BRICK

: WIDTH     C/L@ ;

 L/SCR CONSTANT HEIGHT

VARIABLE DIRECTION
VARIABLE LENGTH

: SNAKE-X ( OFFSET -- ADDRESS )  CELLS SNAKE-X-HEAD + ;
: SNAKE-Y ( OFFSET -- ADDRESS )  CELLS SNAKE-Y-HEAD + ;

: CONVERT-X-Y ( X Y -- OFFSET ) WIDTH * + ;

: DRAW ( char X Y -- )  CONVERT-X-Y  VC! ;

: DRAW-WHITE ( X Y -- ) BL    -ROT DRAW ; \ blank char is white
: DRAW-BLACK ( X Y -- ) SNAKE -ROT DRAW ; \ 42 is snake
: DRAW-BRICK ( X Y -- ) BRICK -ROT DRAW ;

: DRAW-APPLE ( -- ) APPLE-X @ APPLE-Y @ APPLE ROT ROT DRAW ;

: DRAW-WALLS
     WIDTH 0
     DO
       I 0 DRAW-BRICK
       I HEIGHT 1 - DRAW-BRICK
     LOOP

     HEIGHT 0
     DO
        0 I DRAW-BRICK
        WIDTH 1- I DRAW-BRICK
     LOOP ;

: INITIALIZE-SNAKE
      4 LENGTH !
      LENGTH @ 1 + 0
      DO
         12 I - I SNAKE-X !
         12 I SNAKE-Y !
      LOOP
      RIGHT DIRECTION ! ;

: SET-APPLE-POSITION ( y x -- ) APPLE-X ! APPLE-Y ! ;

: INITIALIZE-APPLE ( -- ) 4 4 SET-APPLE-POSITION ;

: INITIALIZE
     GRAPHICS
     12 SCREEN
     MAC  128  CHARDEF
     CLAY  30  CHARDEF
     VIPER 42  CHARDEF
     APPLE SET# 7 1 COLOR
     SNAKE SET# 3 1 COLOR
     BRICK SET# 9 1 COLOR

     WIDTH 0
     DO         \ clear screen the hard way
       HEIGHT 0
       DO
          J I DRAW-WHITE
       LOOP
     LOOP

     DRAW-WALLS
     INITIALIZE-SNAKE
     INITIALIZE-APPLE ;

: MOVE-UP     ( -- ) -1 SNAKE-Y-HEAD +! ;
: MOVE-LEFT   ( -- ) -1 SNAKE-X-HEAD +! ;
: MOVE-DOWN   ( -- )  1 SNAKE-Y-HEAD +! ;
: MOVE-RIGHT  ( -- )  1 SNAKE-X-HEAD +! ;

: MOVE-SNAKE-HEAD
      DIRECTION @
      LEFT  OVER = IF MOVE-LEFT  ELSE
      UP    OVER = IF MOVE-UP    ELSE
      RIGHT OVER = IF MOVE-RIGHT ELSE
      DOWN  OVER = IF MOVE-DOWN  THEN 
      THEN THEN THEN DROP ;

\ move each segment of the snake forward by one
: MOVE-SNAKE-TAIL
    0 LENGTH @
    DO
       I SNAKE-X @ I 1+ SNAKE-X !
       I SNAKE-Y @ I 1+ SNAKE-Y !
    -1 +LOOP ;

: IS-HORIZONTAL  DIRECTION @ DUP  LEFT = SWAP RIGHT = OR ;
: IS-VERTICAL    DIRECTION @ DUP    UP = SWAP  DOWN = OR ;

: TURN-UP        IS-HORIZONTAL IF UP    DIRECTION ! THEN ;
: TURN-LEFT      IS-VERTICAL   IF LEFT  DIRECTION ! THEN ;
: TURN-DOWN      IS-HORIZONTAL IF DOWN  DIRECTION ! THEN ;
: TURN-RIGHT     IS-VERTICAL   IF RIGHT DIRECTION ! THEN ;

: CHANGE-DIRECTION ( key -- )
     [CHAR] S OVER = IF TURN-LEFT  ELSE
     [CHAR] E OVER = IF TURN-UP    ELSE
     [CHAR] D OVER = IF TURN-RIGHT ELSE
     [CHAR] X OVER = IF TURN-DOWN
     THEN THEN THEN THEN DROP ;

: READ-KEY  ( -- c|)  KEY? IF  KVAL C@  ELSE  0  THEN ;

: CHECK-INPUT  ( -- ) READ-KEY CHANGE-DIRECTION ;

\ get random x or y position within playable area
: RANDOM-X ( -- n ) WIDTH 2-  RND 1 + ;
: RANDOM-Y ( -- n ) L/SCR 2-  RND 1 + ;

: MOVE-APPLE
     APPLE-X @ APPLE-Y @ DRAW-WHITE
     RANDOM-Y RANDOM-X SET-APPLE-POSITION
     DRAW-APPLE ;

: GROW-SNAKE ( -- ) 1 LENGTH +! ;

: CHECK-APPLE
     SNAKE-X-HEAD @ APPLE-X @ =
     SNAKE-Y-HEAD @ APPLE-Y @ = AND
     IF BEEP
        MOVE-APPLE
        GROW-SNAKE
     THEN ;

: CHECK-COLLISION ( -- FLAG )
     SNAKE-X-HEAD @ SNAKE-Y-HEAD @  \ get current x/y position
     CONVERT-X-Y VC@                \ get Char at current position
     BL <> ;                        \ compare to blank

: DRAW-SNAKE
     LENGTH @ 0
     DO
        I SNAKE-X @ I SNAKE-Y @ DRAW-BLACK
     LOOP
     LENGTH @ SNAKE-X @
     LENGTH @ SNAKE-Y @
     DRAW-WHITE ;

: SNAKE ( -- )
     BEGIN
        DRAW-SNAKE
        DRAW-APPLE
        130 MS
        CHECK-INPUT
        MOVE-SNAKE-TAIL
        MOVE-SNAKE-HEAD
        CHECK-APPLE
        CHECK-COLLISION
     UNTIL
     HONK  10 8 AT-XY ." GAME OVER"
     250 MS
     KEY DROP GRAPHICS  ;

: START ( -- ) INITIALIZE  SNAKE ;


