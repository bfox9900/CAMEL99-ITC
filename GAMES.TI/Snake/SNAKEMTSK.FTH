\ snake  a simple game in Forth ported to CAMEL99 Forth
\ DERIVED FROM: https://skilldrick.github.io/easyforth/#snake
\ revised to use CAMEL99/TI-99 features
CR .(   \\\\\\ Version 6.1 \\\\\\\\ )
\   \\  snake sounds and mouse squeak  \\\\\

\ v6.2 uses the multi-tasker to animate the mouse

INCLUDE DSK1.RANDOM
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CASE
INCLUDE DSK1.ARRAYS
INCLUDE DSK1.UDOTR
INCLUDE DSK1.SOUND
INCLUDE DSK1.MARKER
INCLUDE DSK1.JOYST
INCLUDE DSK1.DEFER
INCLUDE DSK1.MTASK99

MARKER /SNAKE \ removes snake from the system

\ Simple manager for low RAM block as a heap


CR .( compiling Snake...)
DECIMAL
: NOISE-UP ( speed  -- )
        GEN4  2 15 DO  I DB  DUP MS  -1 +LOOP DROP ;

: NOISE-DOWN ( speed -- )
        GEN4 15  2 DO  I DB  DUP MS     LOOP DROP MUTE ;

DECIMAL
500 CONSTANT MAXLENGTH

\ x/y coordinate storage for the snake
MAXLENGTH ARRAY ]SNAKE-X
MAXLENGTH ARRAY ]SNAKE-Y

: SNAKE-X-HEAD  ( -- addr)  [ 0 ]SNAKE-X ] LITERAL ;
: SNAKE-Y-HEAD  ( -- addr)  [ 0 ]SNAKE-Y ] LITERAL ;

.( .)
VARIABLE SPEED
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
CREATE CLAY   007E , 6A56 , 6A56 , 7E00 ,
CREATE VIPER  3C5E , EBF7 , EBDD , 7E3C ,
CREATE MOUSE  0004 , 3E7B , 7FFC , 8270 ,
CREATE MOUSE2 0008 , 3F7B , 7EFC , 8270 ,  \ mouse looking up
CREATE MOUSE2 84BE , FB7F , 3C42 , 0000 ,

DECIMAL
\ get random x or y position within playable area
: RANDOM-X ( -- n ) C/L@  2-  RND 1+ ;
: RANDOM-Y ( -- n ) L/SCR 2-  RND 1+ ;

\ text macros make drawing faster.
: DRAW-WHITE ( x y -- ) S" >VPOS  BL   SWAP VC! " EVALUATE ; IMMEDIATE
: DRAW-SNAKE ( X Y -- ) S" >VPOS SNAKE SWAP VC! " EVALUATE ; IMMEDIATE
: DRAW-HEAD  ( x y -- ) S" >VPOS SHEAD SWAP VC! " EVALUATE ; IMMEDIATE

: DRAW-PREY ( -- ) PREY  PREY-X @ PREY-Y @ >VPOS VC!  ;
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
       I ]SNAKE-X @   I ]SNAKE-Y @ DRAW-SNAKE
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
      LEFT  OF  -1 SNAKE-X-HEAD +!  ENDOF
      UP    OF  -1 SNAKE-Y-HEAD +!  ENDOF
      RIGHT OF   1 SNAKE-X-HEAD +!  ENDOF
      DOWN  OF   1 SNAKE-Y-HEAD +!  ENDOF
    ENDCASE ;

\ move each segment of the snake forward by one
DECIMAL
\ : MOVE-SNAKE-TAIL
\    0 LENGTH @
\    DO
\       I ]SNAKE-X DUP @ SWAP CELL+ !
\       I ]SNAKE-Y DUP @ SWAP CELL+ !
\    -1 +LOOP ;

: MOVE-SNAKE-TAIL
\      src addr    dest addr      size
\     ---------    --------- -------------
    SNAKE-X-HEAD  DUP CELL+  LENGTH @ CELLS  CMOVE>
    SNAKE-Y-HEAD  DUP CELL+  LENGTH @ CELLS  CMOVE>
 ;

: MOVE-SNAKE  (  -- )
             MOUSE2 PREY CHARDEF
             4 NOISE  8 DB   \ soft white noise
             MOVE-SNAKE-TAIL
             10 DB            \ ramp down noise
             MOVE-SNAKE-HEAD
             12 DB            \ ramp down noise
             MOUSE PREY CHARDEF
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
  \   83C8 OFF   \ set continuous key reading
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
           5 NOISE
           8 NOISE-UP
           20 NOISE-DOWN ;

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
\ ******************************************************************
\ MOUSE coded to run in a separate task and workspace
DECIMAL
: DECAY   ( n -- ) 16 0 DO  I DB  DUP TICKS LOOP DROP ;

: SQUEAK  ( -- )
          GEN4 MUTE
          GEN1 3800 HZ 80 DECAY
          3500 HZ 80 DECAY
          1300 HZ 80 DECAY
          800 HZ  80 DECAY
          MUTE ;

: NEW-MOUSE-LOCATION
    SWOOSH
    PREY-X @ PREY-Y @ DRAW-WHITE
    RANDOM-Y RANDOM-X PLACE-PREY
    500 RND 100 + MS
    DRAW-PREY SQUEAK ;

: KILL-MOUSE
    [ PREY SET# ] LITERAL
    DUP 9 1 COLOR  SQUEAK  2 1 COLOR
;

\ This code will be a task so it runs in an endless loop
DECIMAL
VARIABLE ALIVE  \ message variable to tell mouse task that it is dead
: SCARED-PREY ( -- )
    BEGIN
        BEGIN
        ALIVE @
        WHILE
            PAUSE
            MOUSE2 PREY CHARDEF
            1000 RND 150 +  MS
            PAUSE  MOUSE PREY CHARDEF
        REPEAT

        KILL-MOUSE
        ALIVE ON
        NEW-MOUSE-LOCATION
    AGAIN ;

\ we use space for a task in LOW RAM at HEX 2000
HEX 2000 CONSTANT MOUSE-TASK
: SPAWN-MOUSE  \ create a task that can run indepedent of game loop
    USIZE H !  \ tell system we took "user-size" (196) bytes
    MOUSE-TASK FORK \ copy workspace info into task space
    ['] SCARED-PREY MOUSE-TASK ASSIGN  \ Assign the program to this task.
;
\ *******************************************************************

: FASTER    ( -- ) SPEED @ 5 -  1 MAX SPEED ! ;

: CHECK-PREY  ( -- )
    SNAKE-X-HEAD @ PREY-X @ =
    SNAKE-Y-HEAD @ PREY-Y @ =  AND
    IF
        ALIVE ON

       HAPPY-SNAKE
       GROW-SNAKE
       FASTER
       NEW-PREY
    THEN ;

: COLLISION? ( -- ? )
    SNAKE-X-HEAD @ SNAKE-Y-HEAD @ >VPOS VC@
    DUP  BRICK =
    SWAP SNAKE = OR  ;

\ utility words for menus
: WAIT-KEY   BEGIN KEY? UNTIL ;
: AT"        POSTPONE AT-XY  POSTPONE ." ;  IMMEDIATE

: INITIALIZE
    PAGE
    4 SCREEN
    MOUSE PREY  CHARDEF
    PREY SET#    2 1 COLOR
    CLAY  BRICK CHARDEF
    BRICK SET#   9 1 COLOR
    VIPER SNAKE CHARDEF
    SNAKE SET#  13 1 COLOR
    SHEAD SET#  7 1 COLOR
    DRAW-WALLS
    INITIALIZE-SNAKE
    RANDOM-Y RANDOM-X PLACE-PREY

    ['] READ-KEYBOARD IS READ-DIRECTION
    MOUSE-TASK RESTART
;

.( .)
HEX
: PLAY ( -- )
      BEGIN
         SPEED @ MS
         DRAW-SNAKE
         DRAW-PREY
         READ-DIRECTION
         MOVE-SNAKE
         CHECK-PREY
         COLLISION?
     UNTIL
      0C SCREEN
      HONK
      0B 5 AT" GAME OVER"
      HONK
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
      CASE
          [CHAR] 1 OF 150 ENDOF
          [CHAR] 2 OF 110 ENDOF
          [CHAR] 3 OF  75 ENDOF
          [CHAR] 4 OF  50 ENDOF
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
      5  5 AT" THE SNAKE"
      5  7 AT" Use the E,S,D,X keys"
      5  8 AT" to move the snake
      5  9 AT" and catch the mouse."
      5 12 AT" The more he eats,
      5 13 AT" the faster he goes!"
      5 20 AT" Press any key to begin..."
      WAIT-KEY ;

.( .)

: RUN ( -- )
     TITLE

     SPAWN-MOUSE
     BEGIN
        MENU
        INITIALIZE
        MULTI
        PLAY
        500 MS KEY? DROP ( wait for key release)
        2 13 AT" Your snake was " LENGTH @ . ." Ft. long"
        2 15 AT" Press ENTER to play again"
        KEY 13 <>
     UNTIL
     SINGLE
     GEN4 MUTE
     8 20 AT" SSSSSee you later!"
     1500 MS
     GRAPHICS ;


\ ** Uncomment below to make a binary program
\ CR .( Making binary program ...)
\ LOCK
\ INCLUDE DSK1.SAVESYS
\ ' COLD SAVESYS DSK3.SNAKE62

 \ RUN  \ AUTO START AFTER COMPILE