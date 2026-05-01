\ TI-REX.FTH

\ NEEDS DUMP    FROM DSK1.TOOLS
NEEDS QUIT-ON  FROM DSK1.QUITKEY
NEEDS LOCK     FROM DSK1.MARKER
NEEDS HZ       FROM DSK1.SOUND
NEEDS CALLCHAR FROM DSK1.GRAFIX
NEEDS SPRITE   FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION  DELALL
NEEDS LIME     FROM DSK1.COLORS
NEEDS RND      FROM DSK1.RANDOM
NEEDS VALUE    FROM DSK1.VALUES
NEEDS FORK     FROM DSK1.MTASK99

\ for easier use of Magellan Assembler data
NEEDS DATA     FROM DSK1.DATABYTE

\ *************************
\  TASK 'PID'  CONTAINERS
\ *************************
0 VALUE CACTUS-TASK
0 VALUE GROUND-TASK
0 VALUE ERASER-TASK
\ 0 VALUE SCORE-TASK


\ ****************************************
\           Character Patterns
\ ****************************************
HEX
CREATE PAT128 DATA 0000,0000,FF00,0000    \
CREATE PAT129 DATA 0000,1E61,8000,0000    \
CREATE PAT130 DATA 0000,609E,0100,0000    \
CREATE PAT131 DATA 0000,0000,C040,3E00    \
CREATE PAT132 DATA 0000,0000,0304,F800    \
CREATE PAT133 DATA 0000,0000,FF00,3800    \
CREATE PAT134 DATA 0000,0000,FF00,6060    \
CREATE PAT135 DATA 0000,0000,FF00,0400    \
CREATE PAT136 DATA 0000,0000,FF00,1010    \
CREATE PAT137 DATA 0000,0000,FF00,7004    \


DECIMAL
: DEFINE-CHARS
    PAT128 128 CHARDEF
    PAT129 129 CHARDEF
    PAT130 130 CHARDEF
    PAT131 131 CHARDEF
    PAT132 132 CHARDEF
    PAT133 133 CHARDEF
    PAT134 134 CHARDEF
    PAT135 135 CHARDEF
    PAT136 136 CHARDEF
    PAT137 137 CHARDEF
   128 SET#  144 SET# BLACK CLR COLORS
;

\ DEFINE-CHARS
CREATE GROUND  \ array of 32 characters that draw the ground line
   BYTE 128,129,130,131
   BYTE 132,133,134,135
   BYTE 136,137,128,129
   BYTE 130,131,132,133
   BYTE 134,135,136,137
   BYTE 128,129,130,131
   BYTE 132,133,134,135
   BYTE 136,137,128,129

\  pre-calculate ground line screen addresses in VDP memory
DECIMAL
 0 16 >VPOS CONSTANT 1STDIRT-Y   \ dirt character left side
31 16 >VPOS CONSTANT LASTDIRT-Y  \ dirt character right side

: .GROUND ( -- )  GROUND 1STDIRT-Y 32  VWRITE ;


\ ****************************************
\ * Sprite Patterns
\ ****************************************
HEX
CREATE TREX1
       DATA 0000,0101,0181,81C1    \ Color 1
       DATA E377,7F3F,1F06,0406    \
       DATA 00FE,FFBF,FFF0,FEE0    \
       DATA E0F8,E8E0,C040,6000    \

CREATE TREX2
       DATA 0000,0101,0181,81C1    \ Color 1
       DATA E377,7F3F,1F04,0600    \
       DATA 00FE,FFBF,FFF0,FEE0    \
       DATA E0F8,E8E0,C0C0,80C0    \

CREATE CLOUD1
       DATA 0000,0001,1E20,4048    \ Color 1
       DATA 8700,0000,0000,0000    \
       DATA 0000,E010,1C22,0201    \
       DATA FF00,0000,0000,0000    \

CREATE CACTUS1
       DATA 0001,0303,3333,3333    \ Color 1
       DATA 333F,1F0F,0303,0303    \
       DATA 0080,C0C0,C0C0,CCCC    \
       DATA CCFC,F0C0,C0C0,C0C0    \

CREATE CACTUS2
       DATA 0000,0000,0000,0001    \ Color 1
       DATA 0109,0907,0101,0101    \
       DATA 0000,0000,0000,0080    \
       DATA 80A0,A0A0,E080,8080    \

CREATE CACTUS3
       DATA 0103,3333,3333,333B    \ Color 1
       DATA 1F03,0303,0303,0303    \
       DATA 0080,8080,8098,9898    \
       DATA 9898,98F0,E080,8080    \

CREATE CACTUS4                     \ 3 Cactus clump
      DATA 011B,1B1B,1B2F,27AB
      DATA ABAB,FB63,6363,6363
      DATA 00B0,B0B0,B0E4,C48D
      DATA ADBF,9F8C,8C8C,8C8C

\ word to define 32 byte sprites
: SPRITEDEF  ( addr char -- ) ]PDT  4 8* VWRITE ;

DECIMAL
: DEFINE-SPRITE-CHARS  \ 4 chars wide
   TREX1 140 SPRITEDEF
   TREX2 144 SPRITEDEF
  CLOUD1 148 SPRITEDEF
 CACTUS1 152 SPRITEDEF
 CACTUS2 156 SPRITEDEF
 CACTUS3 160 SPRITEDEF
;

\ DEFINE-SPRITE-CHARS

0 CONSTANT #DINO
1 CONSTANT #CLOUD1
2 CONSTANT #CLOUD2
3 CONSTANT #CLOUD3

118 CONSTANT DIRT-Y  \ vertical level of ground in pixels

: DINO-XY ( -- X Y)  50  DIRT-Y 2+ ;

: MAKE-SPRITES
\  char  color  x   y  sprite#
   140  BLACK  DINO-XY #DINO  SPRITE
   148  WHITE  50   50 #CLOUD1  SPRITE
   148  WHITE  167  40 #CLOUD2  SPRITE
   148  WHITE   80  60 #CLOUD3  SPRITE
;

: MOVE-CLOUDS
     -1 0 #CLOUD1 MOTION
     -1 0 #CLOUD2 MOTION
     -1 0 #CLOUD3 MOTION
;

\ ************************
\ Spawn cactus sprites
\ ************************
VARIABLE SPEED  \ speed of the cactii

VARIABLE CACTUS#   4 CACTUS# !

: CACTUS++  CACTUS# DUP 1+! @ 9 > IF  4 CACTUS# !  THEN ;

\ : TEST   BEGIN  CACTUS# @  .  CACTUS++   ?TERMINAL UNTIL ;

CREATE CACTUSCHARS ( -- ) 152 C, 156 C, 160 C,
: ]CACTUSCHAR ( n -- c) CACTUSCHARS + C@ ;


\ ************************************
\          sprite macros
\ ************************************
: DELSPRITE ( spr# --) S" SP.Y 4  BL  VFILL" EVALUATE ; IMMEDIATE

\ text macro is a bit faster in a loop
: SP.X@     ( spr# -- c) S" SP.X VC@" EVALUATE ; IMMEDIATE


\ **********************************
\          score control
\ **********************************

VARIABLE SCORE
VARIABLE HISCORE
NEEDS .R FROM DSK1.UDOTR

: RESETSCORE       SCORE OFF HISCORE OFF ;
: SET-HISCORE ( --) SCORE @ HISCORE @  MAX HISCORE !  ;

DECIMAL
: .SCORE
   PAUSE
   18 0 AT-XY ." HI " HISCORE @ 5 U.R  SPACE SCORE @ 5 U.R
   PAUSE
   SET-HISCORE ;


\ *************************
\   COINCIDENCE AND STUFF
\ *************************
: BA-BUMP
   GEN1 110 HZ -12 DB 80 MS
   MUTE 70 MS
   6 DB 150 MS
   MUTE ;

8 CONSTANT TOLERANCE

\ ** DECTECTER stops sprite motion and kils multi-tasking **
: DETECTER ( -- ?)
   FALSE \ default flag is false
   10 4  \ scan sprites #4 to $9
   DO
      I SP.PAT VC@ BL <>   \ is sprite assigned a shape?
      IF
         #DINO I TOLERANCE COINC
         OR   \ OR each flag. Any cactus counts
         DUP IF  STOPMOTION SINGLE  LEAVE THEN
      THEN
      PAUSE
   LOOP
;

: SPAWNPOINT ( -- x y) 245  DIRT-Y ; \ cactus start location

\ :-)  kill cactii that are on the left side
: HERBICIDE ( 1stsprite lastsprite -- )
   1+ SWAP
   DO
      PAUSE
      I SP.X@ 11 <
      IF  I DELSPRITE
      THEN
   LOOP
;

: FREE-SPRITE ( -- n)
      FALSE
      10 4   \ scan for unused sprite
      DO
         PAUSE
         I SP.PAT VC@ BL =
         IF
           DROP I LEAVE
         THEN
      LOOP
;

\ scan active sprites for pattern that is not assigned ( pattern= BL)
: WAIT-FREE-SPRITE  ( -- n)
   BEGIN
      PAUSE
      FREE-SPRITE
      ?DUP
   UNTIL
;

\ *************************
\   DINOSAUR JUMP CONTROL
\ *************************

17 CONSTANT HEIGHT
VARIABLE COLLISION  \ global message that a cactus hit TIREX

: GRAVITY   5 TICKS ; \ ticks is a 23.1 micro-second delay

DECIMAL
: JUMPUP ( == ?)
   GEN1  525 HZ 0 DB  \ start the tone
   FALSE
   0 HEIGHT DO
      1  I 2* NEGATE #DINO MOTION
      17 I - DB     \ Fade out fast
      DETECTER OR   \ test for coincidence during jump
   -1 +LOOP
   MUTE
;

: DESCEND ( -- ? )
   FALSE
   HEIGHT 0 DO
      0  I 2*
      #DINO MOTION GRAVITY
      DETECTER
      OR \ test for coincidence during fall
   LOOP

;

: JUMP ( ? -- ?)
   JUMPUP  DESCEND OR ( -- ?)
   SPEED @ 1-  -31 MAX SPEED !
   0 0 #DINO MOTION
;

\ **************************
\        task loops
\ **************************
: CACTUS-GUN
   BEGIN
     4 9 HERBICIDE
     2050 SPEED @ +  RND 90 + MS  \ wait for a random time
     WAIT-FREE-SPRITE >R
     3 RND ]CACTUSCHAR  OLIVE  SPAWNPOINT R@ SPRITE
     SPEED @ 0  R> MOTION
     PAUSE
     CACTUS++
   AGAIN
;

: CACTUS-KILLER   ( -- )
\ searches for cactus at LEFT side of screen and deletes them
   BEGIN
      4 9 HERBICIDE
      PAUSE
   AGAIN
;

: EARTH-MOVER
\ slide the ground line to the left
   BEGIN
      1STDIRT-Y VC@     \ save the 1st character

      1STDIRT-Y PAD 32    PAUSE VREAD  \ Copy line to PAD
      PAD 1+ 1STDIRT-Y 31 PAUSE VWRITE \ write back shifted 1 char

      LASTDIRT-Y VC! \ replace last char with 1st char
      150 SPEED @ +  MS
   AGAIN ;

HEX 83C8 CONSTANT REPEAT-KEY

DECIMAL
: PITTER-PATTER  ( of little dinsosaur feet )
   PAUSE 140 #DINO PATTERN
   800 TICKS
   144 #DINO PATTERN
   800 TICKS
;

DECIMAL
: DINO-LOOP ( -- ? ) \ ? = true if collision detected
   DINO-XY #DINO LOCATE
   FALSE              \ default collision flag = false
   REPEAT-KEY  ON
   BEGIN
      SCORE 1+!
      KEY? BL <>
   WHILE
      DETECTER 0=
   WHILE
      PITTER-PATTER
      .SCORE
   REPEAT
   TRUE OR   EXIT   \ get out early if collision detected
   THEN
   JUMP ( -- ?) \ JUMP also runs the detector
   OR           \ OR with FALSE
;

\ *******************
\  SOME TEXT CONTROL
\ *******************
: ESCAPE
   ?TERMINAL
   IF SINGLE  STOPMOTION
      0 21 AT-XY ." *BREAK*"
      HONK BYE
   THEN ;

: PROMPT:  3 22 AT-XY  VPOS C/L@ BL VFILL ;

: WAIT-KEYUP  BEGIN  PAUSE KEY? 0=  UNTIL ;

: WAIT-SPACE-BAR  ( -- )
  WAIT-KEYUP 100 MS
  BEGIN  ESCAPE KEY? BL = UNTIL
  400 MS ;

: PLAY-AGAIN
   PROMPT: ." PRESS SPACE TO PLAY AGAIN"
   WAIT-SPACE-BAR
   PROMPT:
;

: TITLE
   PAGE GRAY SCREEN
   6 10 AT-XY ."       TI REX"
   6 12 AT-XY ." Adapted by Brian Fox"
   6 14 AT-XY ."        2026"
   2000 MS
   PAGE
;

\ ******************
\   MAIN PROGRAM
\ ******************
: INITS ( -- )
   DEFINE-CHARS
   DELALL
   DEFINE-SPRITE-CHARS
   2 MAGNIFY
;

: .GAME-SCREEN
   CLEAR
   GRAY SCREEN
   .GROUND
   MAKE-SPRITES
   MOVE-CLOUDS
;

: RUN
   CLEAR
   TITLE
   ['] CACTUS-KILLER SPAWN TO ERASER-TASK
   ['] EARTH-MOVER   SPAWN TO GROUND-TASK
   ['] CACTUS-GUN    SPAWN TO CACTUS-TASK

   RESETSCORE
   BEGIN
      INITS
      .GAME-SCREEN
     -20 SPEED !
      SCORE OFF
      WAIT-SPACE-BAR

      AUTOMOTION
      9 MOVING  \ max sprites that are moving under interrupt control

      ERASER-TASK RESTART
      GROUND-TASK RESTART
      CACTUS-TASK RESTART
      MULTI

     \ This is the game loop that runs in console task
      BEGIN
         DINO-LOOP
      UNTIL
      10 SCORE +!  \ successful jump: bonus points
      BA-BUMP
      .SCORE
      PLAY-AGAIN
   AGAIN
;

: GO   WARM DECIMAL INIT-MULTI GRAPHICS QUIT-ON RUN ;

LOCK

INCLUDE DSK1.SAVESYS

' GO SAVESYS DSK3.TIREX
