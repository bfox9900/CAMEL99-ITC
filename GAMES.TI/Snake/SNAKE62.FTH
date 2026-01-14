\ snake  a simple game in Forth ported to CAMEL99 Forth
\ DERIVED FROM: https://skilldrick.github.io/easyforth/#snake
\ revised to use CAMEL99/TI-99 features
CR .(   \\\\\\ Version 6.2 \\\\\\\\ )
\   \\  snake sounds and mouse squeak  \\\\\

CR .( Compiline library files ...)
INCLUDE DSK1.RANDOM
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CASE
INCLUDE DSK1.ARRAYS
INCLUDE DSK1.UDOTR
INCLUDE DSK1.SOUND
INCLUDE DSK1.DEFER
INCLUDE DSK1.JOYST
INCLUDE DSK1.MARKER

CR
CR .( Compiling Snake program ...)
CR
MARKER /SNAKE \ removes snake from the system

\ create some sounds with Forth words HZ DB TICKS MUTE
DECIMAL \ max N = 10000
: DECAY  ( n -- ) 16 0 DO  I DB  DUP I +  TICKS LOOP TICKS MUTE ;


: DECAY2 ( n -- )
    16 0
    DO
        GEN1 I DB   GEN2 I DB
        DUP TICKS
    LOOP
    TICKS
    GEN1 MUTE  GEN2 MUTE ;

: CLINK ( -- ) GEN1 1400 HZ   200 DECAY ;
: PING  ( -- ) GEN3 2000 HZ  1000 DECAY ;
: BONK  ( -- )  GEN1 110 HZ GEN2 111 HZ  500 DECAY2 ;


\ ****************************************
\ * Digit Character Patterns
\ ****************************************
HEX
CREATE NUMBER-FONT
   7CC6 , C6C6 , C6C6 , 7C00  ,  \ 0
   3818 , 1818 , 1818 , 1800  ,  \ 1
   FEC6 , 067C , E0E6 , FE00  ,  \ 2
   FCCC , 0C7E , 0ECE , FE00  ,  \ 3
   FC8C , 8C8C , FE0C , 0C00  ,  \ 4
   FEC0 , FC0E , 0ECE , FE00  ,  \ 5
   7EC6 , C0FC , C6C6 , FE00  ,  \ 6
   FC0C , 0C0C , 1C1C , 1C00  ,  \ 7
   7C4C , 4EFE , 8E8E , FE00  ,  \ 8
   7E46 , 467E , 0E0E , 0E00  ,  \ 9

\ HEX 800 CONSTANT PDT
.( .)

: PATTERNS ( n --) 8* ; \ size of a char pattern in bytes
\ : ]PDT ( ascii# -- Vdp_addr) PATTERNS PDT + ; \ vdp pattern array

DECIMAL
: NEW-DIGITS   NUMBER-FONT  [CHAR] 0 ]PDT  10 PATTERNS VWRITE ;

VARIABLE INCREMENT \ how fast the score goes up (depends on level)
VARIABLE SCORE
VARIABLE SPEED

: COMPENSATED ( n -- n') 150 SPEED @ */  ;

: SCORE++   INCREMENT @ COMPENSATED  SCORE +! ;

\ number formatter
: <#####> ( n -- $ len) DECIMAL  0 <# # # # # # #> ;

\ direct to VDP print score
: PRINTAT ( $ len col row ) >VPOS SWAP VWRITE ;
: .SCORE
  SCORE @ <#####>  25 0 PRINTAT    CLINK PING ;

: NOISE-UP ( speed  -- )
        GEN4  2 15 DO  I DB  DUP TICKS  -1 +LOOP DROP ;

: NOISE-DOWN ( speed -- )
        GEN4 15  2 DO  I DB  DUP TICKS    LOOP TICKS  MUTE ;

DECIMAL
500 CONSTANT MAXLENGTH

\ x/y coordinate storage for the snake
MAXLENGTH ARRAY ]SNAKE-X
MAXLENGTH ARRAY ]SNAKE-Y

: SNAKE-X-HEAD  ( -- addr)  [ 0 ]SNAKE-X ] LITERAL ;
: SNAKE-Y-HEAD  ( -- addr)  [ 0 ]SNAKE-Y ] LITERAL ;

.( .)
VARIABLE PREY-X
VARIABLE PREY-Y
VARIABLE DIRECTION
VARIABLE LENGTH

\ characters used
DECIMAL
136 CONSTANT SHEAD  \ use different color set
42  CONSTANT SNAKE
128 CONSTANT PREY
30  CONSTANT BRICK
BL  CONSTANT WHITE

\ Direction #s
0 CONSTANT LEFT
1 CONSTANT UP
2 CONSTANT RIGHT
3 CONSTANT DOWN

HEX
CREATE HEADLEFT  0C16 , 37FF , FF37 , 160C ,
CREATE HEADUP    1818 , 3C7E , 99FF , 7E3C ,
CREATE HEADRIGHT 3068 , ECFF , FFEC , 6830 ,
CREATE HEADDOWN  3C7E , FF99 , 7E3C , 1818 ,

\ array of head patterns
CREATE HEADS ( n -- addr ) HEADLEFT , HEADUP , HEADRIGHT , HEADDOWN ,

\ set head pattern n to snake's head
: ]HEADPATTERN ( n -- addr) CELLS HEADS + @  SHEAD CHARDEF ;

: FACE  ( direction# -- ) DUP ]HEADPATTERN   DIRECTION ! ;

\ shape data for PREY, brick, mouse and snake chars
HEX
CREATE CLAY   FFBD , DBE7 , E7DB , BDFF , \ 007E , 6A56 , 6A56 , 7E00 ,
CREATE VIPER  3C5E , EBF7 , EBDD , 7E3C ,
CREATE MOUSE  0004 , 3E7B , 7FFC , 8270 ,
CREATE MOUSE2 0008 , 3F7B , 7EFC , 8270 ,  \ mouse looking up

CREATE JUMPMS 84BE , FB7F , 3C42 , 0000 ,

DECIMAL
\ get random x or y position within playable area
: RANDOM-X ( -- n ) C/L@  2-  RND 1+ ;
: RANDOM-Y ( -- n ) L/SCR 2-  RND 1+ ;

\ text macros make drawing faster.
: DRAW-WHITE ( x y -- ) S" >VPOS  BL   SWAP VC! " EVALUATE ; IMMEDIATE
: DRAW-BODY  ( X Y -- ) S" >VPOS SNAKE SWAP VC! " EVALUATE ; IMMEDIATE
: DRAW-HEAD  ( x y -- ) S" >VPOS SHEAD SWAP VC! " EVALUATE ; IMMEDIATE

: DRAW-PREY ( -- )
    MOUSE PREY CHARDEF
    PREY SET#  2 1 COLOR
    PREY  PREY-X @ PREY-Y @ >VPOS VC! ;

.( .)
: DRAW-WALLS
     0  0 BRICK 31 HCHAR
     0  1 BRICK 22 VCHAR
    31  0 BRICK 24 VCHAR
     0 23 BRICK 31 HCHAR ;

: DRAW-SNAKE
    SNAKE-X-HEAD @  SNAKE-Y-HEAD @ DRAW-HEAD
    LENGTH @ 1
    DO
       I ]SNAKE-X @   I ]SNAKE-Y @ DRAW-BODY
    LOOP
    LENGTH @ DUP ]SNAKE-X @  SWAP ]SNAKE-Y @  DRAW-WHITE ;

: INITIALIZE-SNAKE
     6 DUP LENGTH !
     1+ 0
     DO
        12 I - I ]SNAKE-X !
        12 I     ]SNAKE-Y !
     LOOP
     RIGHT FACE  ;

: PLACE-PREY ( y x -- ) PREY-X ! PREY-Y ! ;

: MOVE-SNAKE-HEAD ( n -- )
    DIRECTION @
    CASE
      LEFT  OF   SNAKE-X-HEAD 1-!  ENDOF
      UP    OF   SNAKE-Y-HEAD 1-!  ENDOF
      RIGHT OF   SNAKE-X-HEAD 1+!  ENDOF
      DOWN  OF   SNAKE-Y-HEAD 1+!  ENDOF
    ENDCASE ;

\ move each segment of the snake forward by one
DECIMAL
: MOVE-SNAKE-TAIL
\      src addr    dest addr      size
\     ---------    --------- -------------
    SNAKE-X-HEAD  DUP CELL+  LENGTH @ CELLS  CMOVE>
    SNAKE-Y-HEAD  DUP CELL+  LENGTH @ CELLS  CMOVE>
 ;

: MOVE-SNAKE  (  -- )
            4 NOISE  8 DB   \ soft white noise
            MOVE-SNAKE-TAIL
            10 DB            \ ramp down noise
            MOVE-SNAKE-HEAD
            12 DB            \ ramp down noise
            MUTE ;
.( .)
DECIMAL
: HORIZONTAL? ( -- ?) DIRECTION @ DUP  LEFT = SWAP RIGHT = OR ;
: VERTICAL?   ( -- ?) DIRECTION @ DUP    UP = SWAP  DOWN = OR ;

: TURN-UP        HORIZONTAL? IF UP    FACE  THEN ;
: TURN-LEFT      VERTICAL?   IF LEFT  FACE  THEN ;
: TURN-DOWN      HORIZONTAL? IF DOWN  FACE  THEN ;
: TURN-RIGHT     VERTICAL?   IF RIGHT FACE  THEN ;

DEFER READ-DIRECTION
HEX
: READ-KEYBOARD ( key -- )
  \  83C8 OFF   \ set continuous key reading
    KEY?
    CASE
       [CHAR] S OF TURN-LEFT   ENDOF
       [CHAR] E OF TURN-UP     ENDOF
       [CHAR] D OF TURN-RIGHT  ENDOF
       [CHAR] X OF TURN-DOWN   ENDOF
    ENDCASE
;

\ HEX Outputs from JOYST word
\ 01 = Fire
\ 02 = Left
\ 04 = Right
\ 08 = Down
\ 10 = Up
\ 0A = down+left
\ 0C = down+right
\ 12 = up+left
\ 14 = up+right
HEX
: READ-JOYSTICK
    0 JOYST
    CASE
       2 OF TURN-LEFT  ENDOF
      10 OF TURN-UP    ENDOF
      04 OF TURN-RIGHT  ENDOF
      08 OF TURN-DOWN   ENDOF
    ENDCASE
;

DECIMAL
: SWOOSH   ( -- )
           GEN4 MUTE
           4 NOISE
           500 NOISE-UP
           100 NOISE-DOWN ;

: NEW-PREY
    PREY-X @ PREY-Y @ DRAW-WHITE
    RANDOM-Y RANDOM-X PLACE-PREY
    SWOOSH
    DRAW-PREY ;

: GROW-SNAKE  ( -- ) 1 LENGTH +! ;

: DEAD-SNAKE  ( -- )
             GEN4 MUTE
             SNAKE SET#  DUP 11 1 COLOR  250 MS   2 1 COLOR
             SHEAD SET#  2 1 COLOR  ;

: HAPPY-SNAKE ( -- )
             [ SNAKE SET# ] LITERAL
             17 3
             DO
                DUP I 1 COLOR
                I 100 * HZ 0 DB
                40 MS
            LOOP
            MUTE
            ( -- 5)  13 1 COLOR ;
.( .)
DECIMAL

: SQUEAK      ( -- )
          GEN4 MUTE
         [ PREY SET# ] LITERAL  9 1 COLOR
          GEN1 3800 HZ 0 DB  70 MS
          6 DB  50 MS
          3500 HZ 75 MS
         [ PREY SET# ] LITERAL  8 1 COLOR
          8 DB 50 MS

          1300 HZ  11 DB 50 MS
         [ PREY SET# ] LITERAL  5 1 COLOR

          700 HZ 50 MS
         [ PREY SET# ] LITERAL  15 1 COLOR

          400 HZ 50 MS
         [ PREY SET# ] LITERAL   1 1 COLOR
          GEN1 MUTE ;

DECIMAL
: SCARED-PREY ( -- )
             JUMPMS PREY CHARDEF
             SQUEAK
             MOUSE PREY CHARDEF ;

: %  ( n % -- n')  100 */  ;

: FASTER    ( -- ) SPEED @ 95 %  1 MAX SPEED ! ;

: CHECK-PREY  ( -- )
    SNAKE-X-HEAD @ PREY-X @ =
    SNAKE-Y-HEAD @ PREY-Y @ =  AND
    IF
       SCARED-PREY
       HAPPY-SNAKE
       GROW-SNAKE
       SCORE++ .SCORE
       FASTER
       NEW-PREY
    THEN ;

: COLLISION? ( -- ? )
    SNAKE-X-HEAD @ SNAKE-Y-HEAD @ >VPOS VC@
    DUP  BRICK =  OVER SNAKE = OR
    SWAP [CHAR] 0 [CHAR] 9 1+ WITHIN OR
;

\ utility words for menus
: WAIT-KEY   BEGIN KEY? UNTIL ;
: AT"        POSTPONE AT-XY  POSTPONE ." ;  IMMEDIATE

: INITIALIZE
    PAGE
    4 SCREEN
    CLAY  BRICK CHARDEF
    BRICK SET#   9 1 COLOR
    VIPER SNAKE CHARDEF
    SNAKE SET#  13 1 COLOR
    SHEAD SET#  7 1 COLOR
    DRAW-WALLS
    INITIALIZE-SNAKE
    RANDOM-Y RANDOM-X PLACE-PREY
    NEW-DIGITS
    MOUSE PREY CHARDEF
;

.( .)

HEX
: PLAY ( -- )
    SCORE OFF  .SCORE
    BEGIN
        SPEED @ MS
        DRAW-SNAKE
        DRAW-PREY
        READ-DIRECTION
        MOVE-SNAKE
        CHECK-PREY
        COLLISION?
    UNTIL
    BONK 300 MS
    0C SCREEN
    0B 5 AT" GAME OVER"
    DEAD-SNAKE ;

DECIMAL
: ENDGAME
  5 14 AT" You sure? (Y/N)"
  KEY [CHAR] Y =
  IF    PAGE ABORT
  ELSE  5 14 >VPOS 26 BL VFILL
  THEN  CLEAR ABORT
;

DECIMAL

: GET-LEVEL ( -- speed)
      5 13 AT-XY
      BEGIN
       KEY DUP [CHAR] 1 [CHAR] 6 WITHIN 0=
       WHILE
         DROP
      REPEAT
      DUP  [CHAR] 0 -  INCREMENT !
      CASE
          [CHAR] 1 OF 150  ENDOF
          [CHAR] 2 OF 110  ENDOF
          [CHAR] 3 OF  80  ENDOF
          [CHAR] 4 OF  50  ENDOF
          [CHAR] 5 OF ENDGAME ENDOF
      ENDCASE
;

: MENU
     PAGE
     5 5 AT" Select Start Level"
     5 8 AT" 1 - SNAIL"
     5 9 AT" 2 - WORM"
    5 10 AT" 3 - SNAKE
    5 11 AT" 4 - VIPER"
    5 12 AT" 5 - Quit
    3 23 AT" (It goes faster as you win)"
    GET-LEVEL SPEED !
;


DECIMAL
: TITLE  ( -- )
    GRAPHICS
    5  5 AT" THE SNAKE V6.2"
    3  7 AT" Use ESDX keys or Joystick 1"
    3  8 AT" to move the snake
    3  9 AT" and catch the mouse."

    5 12 AT" The more he eats,
    5 13 AT" the faster he goes!"

    5 15 AT" The faster he goes..."
    5 16 AT" the more points you get!"


    5 20 AT" Press any key to begin..."
    WAIT-KEY ;

: JOYSTICK-TEST
    BEGIN
       0 JOYST 1 <>
    WHILE
       KEY? BL <>
    WHILE
    REPEAT
        ['] READ-KEYBOARD IS READ-DIRECTION
        5 16 AT" Keyboard selected ... "   500 MS
        EXIT
    THEN
    ['] READ-JOYSTICK IS READ-DIRECTION
    5 16 AT" Joystick selected ..." 500 MS
;

: CONTROL-SELECTOR
    PAGE
    2 10 AT" Press FIRE to use joystick 1"
    2 13 AT" Press SPACE to use keyboard"
    JOYSTICK-TEST
;

.( .)
: RUN ( -- )
     TITLE
     CONTROL-SELECTOR
     BEGIN
        MENU
        INITIALIZE
        PLAY
        500 MS KEY? DROP ( wait for key release)
        2 13 AT" Your snake was " LENGTH @ . ." Ft. long"
        2 15 AT" Press ENTER to play again"
        KEY 13 <>
     UNTIL
     GEN4 MUTE
     8 20 AT" SSSSSee you later!"
     1500 MS
     GRAPHICS ;

: START   WARM RUN  BYE ;

LOCK
INCLUDE DSK1.SAVESYS
' START SAVESYS DSK3.SNAKE

RUN
