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
0 VALUE SCORE-TASK
0 VALUE FLYER-TASK


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
   128 SET#  180 SET# BLACK CLR COLORS
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
      DATA 0000,0101,0181,81C1
      DATA E377,7F3F,1F06,0406
      DATA 00FE,FFBF,FFF0,FEE0
      DATA E0F8,E8E0,C040,6000

CREATE TREX2
      DATA 0000,0101,0181,81C1
      DATA E377,7F3F,1F04,0600
      DATA 00FE,FFBF,FFF0,FEE0
      DATA E0F8,E8E0,C0C0,80C0

\ *************************************************************
\ *IMPORTANT*
\ The crouched sprites are positioned in the upper half of the
\ 4 quadrant sprite. This means we have lower the crouched
\ sprites vertically by 8 pixels so they do not collide with
\ a sprite flying over head.

CREATE CROUCH1                    \ crouched Trex
      DATA 8080,CFFF,7F3F,0604,0600,0000,0000,0000
      DATA 1C3E,F7FF,F8DE,80C0,0000,0000,0000,0000

CREATE CROUCH2                    \ Crouched Trex, other foot up
      DATA 8080,CFFF,7F3F,0406,0000,0000,0000,0000
      DATA 1C3E,F7FF,F8DE,C080,C000,0000,0000,0000

\ *****************************************************************

CREATE CLOUD1
      DATA 0000,0001,1E20,4048
      DATA 8700,0000,0000,0000
      DATA 0000,E010,1C22,0201
      DATA FF00,0000,0000,0000

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

CREATE OUCH                   \ spells OUCH as sprite
      DATA 0000,0000,0102,020A
      DATA 0512,0966,9090,6000
      DATA 0020,1098,6420,1020
      DATA C000,0000,0000,0000

CREATE PTEROUP
      DATA 0000,0000,0509,39ED,3F63,0100,0100,0000
      DATA 0830,60C0,C0C0,C0E0,FFE0,8080,0000,0000

CREATE PTEROMID
      DATA 0000,0000,0408,38ED,3F63,0100,0100,0000
      DATA 0000,0000,0000,00C0,FFE0,C080,0000,0000

CREATE PTERODN
      DATA 0000,0000,0408,38ED,3F63,0101,0100,0000
      DATA 0000,0000,0000,00E0,FFE0,C0C0,C0E0,3008

DECIMAL
\ word to define 32 byte sprites
: SPRITEDEF  ( addr char -- ) ]PDT  4 8* VWRITE ;

\ Pterodactyl animation characters
164 CONSTANT wingsup
168 CONSTANT wingsmid
172 CONSTANT wingsdn


DECIMAL
: DEFINE-SPRITE-CHARS  \ 4 chars wide
\ pattern char
   TREX1  140 SPRITEDEF
   TREX2  144 SPRITEDEF
  CLOUD1  148 SPRITEDEF
 CACTUS1  152 SPRITEDEF
 CACTUS2  156 SPRITEDEF
 CACTUS3  160 SPRITEDEF

 PTEROUP  wingsup  SPRITEDEF
 PTEROMID wingsmid SPRITEDEF
 PTERODN  wingsdn  SPRITEDEF
;

\ ***********************
\  NAMED SPRITE NUMBERS
\ ***********************
DECIMAL
0 CONSTANT #DINO
1 CONSTANT #CLOUD1
2 CONSTANT #CLOUD2
3 CONSTANT #CLOUD3

10 CONSTANT #PTERODACTYL

\ vertical level of ground in pixels
118 CONSTANT DIRT-Y

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
   18 0 AT-XY ." HI " HISCORE @ 5 U.R  PAUSE SPACE SCORE @ 5 U.R
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
   11 4  \ scan sprites #4 to #PTERODACTYL
   DO
    \  I SP.PAT VC@ BL <>   \ is sprite assigned a shape?
    \  IF
         #DINO I TOLERANCE COINC
         OR   \ OR each flag. Any cactus counts
         DUP IF  STOPMOTION SINGLE  LEAVE THEN
    \  THEN
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
      9 4   \ scan for unused sprite
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

15 CONSTANT HEIGHT

: GRAVITY   7 TICKS ; \ ticks is a 23.1 micro-second delay

DECIMAL
: JUMPUP ( == ?)
   GEN1  525 HZ 0 DB  \ start the tone
   FALSE
   0 HEIGHT
   DO PAUSE
      1  I 2* NEGATE #DINO MOTION
      17 I - DB     \ Fade out fast
      DETECTER OR   \ test for coincidence during jump
   -1 +LOOP
   MUTE
;

: DESCEND ( -- ? )
   FALSE
   HEIGHT 0 DO
      PAUSE
      0  I 2* #DINO MOTION  \ GRAVITY
      DETECTER
      OR \ test for coincidence during fall
   LOOP
;

: JUMP ( ? -- ?)
   JUMPUP  DESCEND OR ( -- ?)
   SPEED @ 1-  -31 MAX SPEED !
   0 0 #DINO MOTION
;

\ *********************
\  SOME TEXT CONTROLS
\ *********************

: PROMPT:  3 22 AT-XY  VPOS C/L@ BL VFILL ;

: ESCAPE
   ?TERMINAL
   IF SINGLE  STOPMOTION
      PROMPT: ." *Camel99 Forth*"
      1000 MS
      CR ." Bye!"
      500 MS
      CR ABORT
   THEN ;

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

\ ***********************
\ PTERODACTYL ANIMATOR
\ ***********************
\ sequence of flapping characters to make animation
CREATE FLAP-STRIP
   wingsup , wingsmid , wingsdn , wingsmid ,
   wingsup , wingsmid , wingsdn , wingsmid ,

VARIABLE FRAME#
: FRAME#@++   ( -- n) FRAME# @ 1+ 7 AND DUP FRAME# ! ;
: PTERO-CHAR ( -- char ) FRAME#@++ CELLS FLAP-STRIP + @  ;

: .Pterodactyl ( -- ) \ spawn the flying dinosaur sprite
   PTERO-CHAR  PURPLE  245 111 #PTERODACTYL SPRITE ;

\ **************************
\        task loops
\ **************************
: FLYING-DINO ( -- ) \ endless loop. Randomly spawns a Pterodactyl
   BEGIN
    12000 RND 3000 + MS  \ random start time   3 to 15 seconds
    .Pterodactyl
    -34 0 #PTERODACTYL MOTION  \ fly fast left
     BEGIN
         PAUSE
         PTERO-CHAR #PTERODACTYL PATTERN
         150 MS
         #PTERODACTYL SP.X@ 10 <  \ fly until X=9
     UNTIL
     #PTERODACTYL DELSPRITE       \ erase myself
   AGAIN
;

: WAIT-FOR-BIRD
   BEGIN
      #PTERODACTYL SP.PAT VC@  \ read the birds pattern
      BL =                     \ loop until it's a space ie: deleted sprite
   UNTIL
;

\ CACTUS GUN NOW WAITS UNTIL THERE IS NO FLYING DINO IN THE AIR
: CACTUS-GUN
   BEGIN
     4 10 HERBICIDE
     2450 SPEED @ +  RND 500 + MS  \ wait for a random time
  \  WAIT-FOR-BIRD
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
      4 10 HERBICIDE
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
      TRUE OR  EXIT   \ get out early if collision detected
   THEN
   JUMP ( -- ?)       \ JUMP also runs the detector
   OR                 \ OR with FALSE
;

: TITLE
   PAGE GRAY SCREEN
   6 10 AT-XY ."       TI REX"
   6 12 AT-XY ." Adapted by Brian Fox"
   6 14 AT-XY ."  Version II, 2026"
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
   ['] FLYING-DINO   SPAWN TO FLYER-TASK

   RESETSCORE
   BEGIN
   \ reset the game
      INITS
      .GAME-SCREEN
     -20 SPEED !
      SCORE OFF
      WAIT-SPACE-BAR

      AUTOMOTION
      12 MOVING  \ max sprites that are moving under interrupt control

      ERASER-TASK RESTART
      GROUND-TASK RESTART
      CACTUS-TASK RESTART
      FLYER-TASK  RESTART
      MULTI

   \ run the game loop in console task
      BEGIN
         DINO-LOOP
      UNTIL
      BA-BUMP
      .SCORE
      PLAY-AGAIN
   AGAIN
;

\ : GO   WARM DECIMAL INIT-MULTI GRAPHICS QUIT-ON RUN ;

\ LOCK
\ INCLUDE DSK1.SAVESYS
\ ' GO SAVESYS DSK3.TIREX
