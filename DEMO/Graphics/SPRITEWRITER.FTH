\ SPRITEWRITER.FTH  write short words with SPRITES  Feb 2026 BJF
NEEDS .S         FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS RED        FROM DSK1.COLORS
NEEDS HZ         FROM DSK1.SOUND
NEEDS RND        FROM DSK1.RANDOM

DECIMAL
: DELAYS   ( -- ) 0 ?DO PAUSE LOOP ;  \ simple delay loop ~106uS/loop
: ATTACK ( time -- )
         ?DUP 0= IF 0 DB EXIT THEN
         0 15 DO   I DB  DUP DELAYS    -1 +LOOP DROP  ;

: ONTIME ( time -- ) ?DUP 0> IF  DELAYS   THEN  ;

: DECAY  ( time -- )
         ?DUP 0= IF MUTE  EXIT THEN
         16 0 DO  I DB DUP DELAYS   LOOP DROP MUTE ;

: ENVELOPE ( attack on decay --) ROT  ATTACK  SWAP ONTIME  DECAY ;

DECIMAL
: TINK  ( --  ) GEN1 2000 HZ   0  30 15  ENVELOPE ;

: GUNSHOT ( -- )
    -4 NOISE  0 500 0 ENVELOPE
    -1 NOISE  16 5 DO I DB 105 DELAYS LOOP MUTE
;


: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;
1 ( set 1st color)
ENUM CLR        ENUM BLACK      ENUM GREEN      ENUM LIME
ENUM BLUE       ENUM SKY        ENUM RED        ENUM CYAN
ENUM RUST       ENUM ORANGE     ENUM YELLOW     ENUM LEMON
ENUM OLIVE      ENUM PURPLE     ENUM GRAY       ENUM WHITE
DROP

CREATE RAINBOW ( -- addr) RED , ORANGE , YELLOW , GREEN , BLUE , PURPLE ,
VARIABLE NC
: RAINBOW ( -- color#)
   NC @  CELLS RAINBOW + @
   NC DUP 1+! @  5 > IF NC OFF THEN  ;

: DELSPRITE ( spr# -- ) 0 SWAP SP.PAT VC! ;

\ Shoot a sprite from the turret location to (x,y)

\ sprite position management
VARIABLE SPRITE#  \ next sprite to use
VARIABLE LETTER-COLOR   RED LETTER-COLOR !

CREATE SPXY 0 , 0 ,  \ in pixels
SPXY      CONSTANT SPY
SPY CELL+ CONSTANT SPX

: SP.CR   SPY @ 8 + SPY !  SPX OFF   OUT OFF  ;
: XY>PIXELS   8* 2+ SWAP 8* 2+ SWAP  ;
: SP.AT  ( col row ) XY>PIXELS SPXY 2! ;


HEX
01F CONSTANT SPMASK
: LETTERS  LETTER-COLOR ! ;

VARIABLE 1STLETTER


DECIMAL
: NEXT.SPRITE
    10 SPX +!
    OUT 1+!
    SPRITE# @ 1+  SPMASK AND SPRITE# !
;

: SP.EMIT ( char )
\       color          x,y      spr#
    LETTER-COLOR @   SPXY 2@  SPRITE# @  SPRITE
    NEXT.SPRITE
;

: SP.TYPE ( addr len ) BOUNDS ?DO  I C@ SP.EMIT  LOOP  ;

: .MSG
  CLEAR
  DELALL   SPRITE# OFF
  1 MAGNIFY
  BLUE LETTERS
  2  0 SP.AT S" May" SP.TYPE TINK
  2  3 SP.AT S" the" SP.TYPE TINK

 WHITE LETTERS
  SPRITE# @ 1STLETTER !      \ Remember the "F"
  9   5 SP.AT S" F" SP.TYPE TINK
  11  7 SP.AT S" O" SP.TYPE TINK
  13  9 SP.AT S" R" SP.TYPE TINK
  15 11 SP.AT S" T" SP.TYPE TINK
  17 13 SP.AT S" H" SP.TYPE TINK

BLUE LETTERS
  19 16 SP.AT S" be" SP.TYPE TINK
  21 18 SP.AT S" with" SP.TYPE TINK
RUST LETTERS
  23 20 SP.AT S" YOU!" SP.TYPE TINK
;

: TURRET ( -- x y )  120 190 ; \ pixels

: DELTA ( x y x2 y2  -- x' y')
        ROT  - 2/   >R    \ delta Y/2 pushed to Rstack
        SWAP - 2/         \ delta X/2
        R> ;              \ bring back delta Y


: SHOOT.EMIT ( char )
    LETTER-COLOR @  TURRET  SPRITE# @  SPRITE  0 0 SPRITE# @ MOTION
    TURRET  SPXY 2@  DELTA   SPRITE# @ MOTION
    GUNSHOT
    312 MS

    0 0 SPRITE# @ MOTION
    TINK
    SPXY 2@  SPRITE# @ LOCATE

    NEXT.SPRITE
    400 MS
;

DECIMAL
: SP.SHOOT ( addr len ) BOUNDS ?DO  I C@ SHOOT.EMIT  LOOP  ;

: SHOOT.MSG
  CLEAR
  DELALL   SPRITE# OFF
  1 MAGNIFY
  BLUE LETTERS
  2  0 SP.AT S" May" SP.SHOOT
  2  3 SP.AT S" the" SP.SHOOT

 WHITE LETTERS
  SPRITE# @ 1STLETTER !      \ Remember the "F"
  9   5 SP.AT S" F" SP.SHOOT
  11  7 SP.AT S" O" SP.SHOOT
  13  9 SP.AT S" R" SP.SHOOT
  15 11 SP.AT S" T" SP.SHOOT
  17 13 SP.AT S" H" SP.SHOOT

BLUE LETTERS
  19 16 SP.AT S" be" SP.SHOOT
  21 18 SP.AT S" with" SP.SHOOT
RUST LETTERS
  23 20 SP.AT S" YOU!" SP.SHOOT
;

: RISE ( spr# ) -6  SWAP ]SMT.Y VC! ;
: SCROLL-EM  SPRITE# @ 0 DO  I RISE  LOOP ;


: COLOR-FORTH
  5 0
  DO
      RAINBOW   1STLETTER @ I + SP.COLOR
  LOOP
;

: NEWCOLOR ( SPR# -- ) RAINBOW  SWAP SP.COLOR  5 MS  ;

: COLORWHEEL
    8 0
    DO
        5 0
        DO
            6  NEWCOLOR
            7  NEWCOLOR
            8  NEWCOLOR
            9  NEWCOLOR
           10  NEWCOLOR
        LOOP
    LOOP
    COLOR-FORTH
;

: RUN
   AUTOMOTION
   22 MOVING
   BLACK SCREEN
   BEGIN
      SPRITE# OFF
      SHOOT.MSG
      COLORWHEEL
      4 0 DO
        DELALL
        .MSG
        400 MS
      LOOP
      DELALL
      ?TERMINAL
   UNTIL
   STOPMOTION DELALL
   CYAN SCREEN
;
