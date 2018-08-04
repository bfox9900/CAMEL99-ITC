\ snake  a simple game in Forth ported to CAMEL99 Forth
\ DERIVED FROM: https://skilldrick.github.io/easyforth/#snake
\ revised to use CAMEL99/TI-99 features
\   \\\\\\\\\\\ Version 4 \\\\\\\\\\\\\\\\
\   \\  snake sounds and mouse squeak  \\\\\

INCLUDE DSK1.RANDOM.F
INCLUDE DSK1.GRAFIX.F

\ =======================================
\ We use direct control of the sound chip
\ rather than sound lists and a player.

\ noise control words
: NOISE   ( n -- ) E0 OR SND! ; \ n selects the noise type

\ noise envelope control
: NOISE-DB   ( db --) F MIN F0 OR SND! ;
: NOISE-OFF  ( -- )   F NOISE-DB ;

HEX
: NOISE-UP   ( speed  -- ) 
             2  F  DO  I NOISE-DB  DUP MS   -1 +LOOP DROP ;

: NOISE-DOWN ( speed -- )
             F  2  DO  I NOISE-DB  DUP MS     LOOP DROP NOISE-OFF ;

\ channel 1 sound control words

DECIMAL
: f(clk) ( -- d) 46324 1  ;   \ this is 111,860 as 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
: >FCODE   ( 0abc -- 0cab)    \ ASM would make this much faster
           DUP 0F AND SWAP      ( -- 000c 0abc)
           4 RSHIFT             ( -- 000c 00ab)
           SWAP ><  ( SWPB)     ( -- 00ab 0c00)
           + ;

: HZ>CODE  ( freq -- fcode )  f(clk) ROT UM/MOD NIP >FCODE 8000 OR  ;

\ *TRICKY STUFF*
\ Calculating the 9919 freq. code takes too long BUT we can convert frequency
\ to 9919 chip code at compile time then compile as 16 bit literal number
\ using this text MACRO
: [HZ] ( freq -- fcode ) S" HZ>CODE ] LITERAL" EVALUATE ;

\ sound channel #1 control words
: FREQ!    ( fcode -- ) SPLIT SND! SND! ;
: ]HZ      ( freq -- ) [HZ] POSTPONE FREQ! ;      \ pre-compiled fcode version
: HZ       ( freq -- )  HZ>CODE SPLIT SND! SND! ; \ runtime calculation version
: DB       ( n -- )    90 OR SND! ;
: MUTE     ( -- )      9F SND! ;

DECIMAL
500 CONSTANT MAXLENGTH

\ x/y coordinate storage for the snake
CREATE SNAKE-X-HEAD  MAXLENGTH CELLS ALLOT
CREATE SNAKE-Y-HEAD  MAXLENGTH CELLS ALLOT

VARIABLE SPEED
VARIABLE PREY-X
VARIABLE PREY-Y
VARIABLE DIRECTION
VARIABLE LENGTH

0 CONSTANT LEFT
1 CONSTANT UP
2 CONSTANT RIGHT
3 CONSTANT DOWN

\ characters used
128 CONSTANT PREY
42  CONSTANT SNAKE
30  CONSTANT BRICK
BL  CONSTANT WHITE

\ shape data for PREY, brick, mouse and snake chars
HEX
007E 6A56 6A56 7E00 PATTERN: CLAY
3C5E EBF7 EBDD 7E3C PATTERN: VIPER
0004 3E7B 7FFC 8270 PATTERN: MOUSE
0008 3F7B 7EFC 8270 PATTERN: MOUSE2 \ mouse looking up
84BE FB7F 3C42 0000 PATTERN: JUMPMS

DECIMAL
\ get random x or y position within playable area
: RANDOM-X ( -- n ) C/L@  2-  RND 1+ ;
: RANDOM-Y ( -- n ) L/SCR 2-  RND 1+ ;

\ create snake coordiinate arrays
: ]SNAKE-X ( index -- address )  CELLS SNAKE-X-HEAD + ;
: ]SNAKE-Y ( index -- address )  CELLS SNAKE-Y-HEAD + ;

\ text macros make drawing faster.
: >VPOS ( x y -- vaddr)  S" C/L@ * + " EVALUATE ; IMMEDIATE
: DRAW ( char X Y -- ) S" C/L@ * +  VC!" EVALUATE ; IMMEDIATE

: DRAW-WHITE ( x y -- ) BL -ROT DRAW ;
: DRAW-SNAKE ( X Y -- ) SNAKE -ROT DRAW ;

: DRAW-PREY ( -- ) PREY  PREY-X @ PREY-Y @  DRAW ;

: DRAW-WALLS
      0  0 BRICK 31 HCHAR
      0  1 BRICK 22 VCHAR
     31  0 BRICK 24 VCHAR
      0 23 BRICK 31 HCHAR ;

: DRAW-SNAKE
     LENGTH @ 0
     DO
        I ]SNAKE-X @   I ]SNAKE-Y @   DRAW-SNAKE
     LOOP
     LENGTH @ ]SNAKE-X @  LENGTH @ ]SNAKE-Y @  DRAW-WHITE ;

: INITIALIZE-SNAKE
      4 DUP 
      LENGTH !
      1+ 0
      DO
         12 I - I ]SNAKE-X !
         12 I ]SNAKE-Y !
      LOOP
      RIGHT DIRECTION ! ;

: PLACE-PREY ( y x -- ) PREY-X ! PREY-Y ! ;

: MOVE-UP     ( -- ) -1 SNAKE-Y-HEAD +! ;
: MOVE-LEFT   ( -- ) -1 SNAKE-X-HEAD +! ;
: MOVE-DOWN   ( -- )  1 SNAKE-Y-HEAD +! ;
: MOVE-RIGHT  ( -- )  1 SNAKE-X-HEAD +! ;

: MOVE-SNAKE-HEAD ( -- )
     DIRECTION @
     LEFT  OVER = IF MOVE-LEFT  ELSE
     UP    OVER = IF MOVE-UP    ELSE
     RIGHT OVER = IF MOVE-RIGHT ELSE
     DOWN  OVER = IF MOVE-DOWN
     THEN THEN THEN THEN DROP ;

\ move each segment of the snake forward by one
HEX
: MOVE-SNAKE-TAIL
     0 LENGTH @
     DO
        I ]SNAKE-X @ I 1+ ]SNAKE-X !
        I ]SNAKE-Y @ I 1+ ]SNAKE-Y !
     -1 +LOOP ;

: MOVE-SNAKE  (  -- )
              MOUSE2 PREY  CHARDEF
              4 NOISE  B NOISE-DB     \ soft white noise
              MOVE-SNAKE-TAIL 9 NOISE-DB
              MOVE-SNAKE-HEAD D NOISE-DB
              NOISE-OFF 
              MOUSE PREY  CHARDEF ;

DECIMAL
: HORIZONTAL? ( -- ?) DIRECTION @ DUP  LEFT = SWAP RIGHT = OR ;
: VERTICAL?   ( -- ?) DIRECTION @ DUP    UP = SWAP  DOWN = OR ;

: TURN-UP        HORIZONTAL? IF UP    DIRECTION ! THEN ;
: TURN-LEFT      VERTICAL?   IF LEFT  DIRECTION ! THEN ;
: TURN-DOWN      HORIZONTAL? IF DOWN  DIRECTION ! THEN ;
: TURN-RIGHT     VERTICAL?   IF RIGHT DIRECTION ! THEN ;

: CHANGE-DIRECTION ( key -- )
     [CHAR] S OVER = IF TURN-LEFT  ELSE
     [CHAR] E OVER = IF TURN-UP    ELSE
     [CHAR] D OVER = IF TURN-RIGHT ELSE
     [CHAR] X OVER = IF TURN-DOWN
     THEN THEN THEN THEN DROP ;

\ read key is also the delay loop since KSCAN takes 1.1 mS
\ much more responsive to keys than a delay loop
HEX

: READ-KEY  ( -- char | 0)
        83C8 OFF
        KEY? 
        IF KVAL C@
        ELSE 0  
        THEN  ;

DECIMAL
: CHECK-INPUT  ( -- ) READ-KEY CHANGE-DIRECTION ;

: SWOOSH      ( -- )
            NOISE-OFF
            5 NOISE
            8 NOISE-UP
            20 NOISE-DOWN ;

: NEW-PREY
     SWOOSH
     PREY-X @ PREY-Y @ DRAW-WHITE
     RANDOM-Y RANDOM-X PLACE-PREY
     DRAW-PREY ;

: GROW-SNAKE  ( -- ) 1 LENGTH +! ;

: DEAD-SNAKE  ( -- )
              NOISE-OFF
              SNAKE SET#  DUP 11 1 COLOR  250 MS   2 1 COLOR ;


: HAPPY-SNAKE ( -- )
              [ SNAKE SET# ] LITERAL
              12 4 DO
                     DUP I 1 COLOR
                     40 MS
                   LOOP
               ( -- 5)  11 1 COLOR ;

DECIMAL
: DECAY        ( n -- ) 16 0 DO  I DB  DUP MS LOOP DROP ;

: SQUEAK      ( -- )
               NOISE-OFF
               [ 3800 ]HZ 0 DB  45 MS  \ pre-computed freq. is faster
               6 DB  25 MS
               [ 3500 ]HZ 75 MS
                8 DB 25 MS
              [ 1300 ]HZ
               11 DB 25 MS
               [ 800 ]HZ
               MUTE ;
DECIMAL
: SCARED-PREY ( -- )
              JUMPMS PREY CHARDEF
              SQUEAK
             [ PREY SET# ] LITERAL  DUP  9 1 COLOR
              2 1 COLOR
              MOUSE PREY CHARDEF ;

: FASTER       SPEED @ 5 -  5 MAX SPEED ! ;

: CHECK-PREY
     SNAKE-X-HEAD @ PREY-X @ =
     SNAKE-Y-HEAD @ PREY-Y @ =  AND
     IF
        SCARED-PREY
        HAPPY-SNAKE
        GROW-SNAKE
        FASTER
        NEW-PREY
     THEN ;

: COLLISION? ( -- ? )
     SNAKE-X-HEAD @ SNAKE-Y-HEAD @ >VPOS VC@
     DUP BRICK =
     SWAP SNAKE = OR  ;

\ utility words for menus
: WAIT-KEY   BEGIN KEY? UNTIL ;
: AT"   POSTPONE AT-XY  POSTPONE ." ;  IMMEDIATE

: INITIALIZE
     PAGE
     4 SCREEN

     MOUSE PREY  CHARDEF   [ PREY SET# ]  LITERAL  2 1 COLOR
     CLAY  BRICK CHARDEF   [ BRICK SET# ] LITERAL  9 1 COLOR
     VIPER SNAKE CHARDEF   [ SNAKE SET# ] LITERAL 11 1 COLOR

     DRAW-WALLS
     INITIALIZE-SNAKE
     RANDOM-Y RANDOM-X PLACE-PREY
     125 SPEED !  ;

: PLAY ( -- )
       BEGIN
          DRAW-SNAKE
          DRAW-PREY
          CHECK-INPUT 
          MOVE-SNAKE
          CHECK-PREY
          COLLISION?
          SPEED @ MS
       UNTIL
       HONK 12 10 AT" GAME OVER"
       HONK
       DEAD-SNAKE ;

DECIMAL
: TITLE  ( -- )
       GRAPHICS
       5  5 AT" THE SNAKE"
       5  7 AT" Use the E,S,D,X keys"
       5  8 AT" to move the snake
       5  9 AT" and catch the mouse."
       5 12 AT" The more he eats,
       5 13 AT" the faster he goes!"
       5 20 AT" Press any key to begin..."
       WAIT-KEY ;

: RUN ( -- )
      TITLE
      BEGIN
         INITIALIZE
         PLAY
         5 13 AT" Your snake was " LENGTH @ . ." Ft. long"
         5 15 AT" Press ENTER to play again"
         KEY 13 <>
      UNTIL
      NOISE-OFF
      8 20 AT" SSSSSee you later!"
      1500 MS
      GRAPHICS ;


