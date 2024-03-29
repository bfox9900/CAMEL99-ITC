\ Sprite COINC and COINCY Test

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RNDV       FROM DSK1.RANDOM
NEEDS FORK       FROM DSK1.MTASK99


MARKER /TEST

DECIMAL
: SP.STOP  ( spr# ) 0 0 ROT MOTION ;

: TINK    GEN1 1600 HZ -6 DB 900 TICKS  ;
: THUMP   GEN2  150 HZ  0 DB  ;


: BOUNCE.X  ( spr# -- ) ]SMT.X  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE.Y  ( spr# -- ) ]SMT.Y  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE    ( spr# -- ) DUP BOUNCE.X BOUNCE.Y 500 TICKS ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      239 0 WITHIN IF  BOUNCE.X  TINK  EXIT THEN
      DROP ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      185 0 WITHIN IF  BOUNCE.Y  TINK  EXIT THEN
      DROP ;

: TRAP ( spr# -- ) DUP TRAPX TRAPY ;

: RAINBOW  ( spr# -- )
       THUMP
       16 3
       DO
          I OVER SP.COLOR
          SPR# @ 0 DO I TRAP LOOP  \ keep the other guys trapped while waiting
          GEN2 I DB                \ FADE the sound down
       LOOP
       DROP MUTE ;


: COLLISION ( spr1 spr2 -- )
        2DUP 9 COINC
        IF   THUMP
    ( spr2)  BOUNCE
    ( spr1)  DUP BOUNCE RAINBOW
             EXIT
        THEN
        2DROP
;

DECIMAL
: RNDV ( -- x y) 60 RND 30 - ;
: RNDXY    RNDV RNDV ;

: SPRITES ( n -- )
    0 ?DO
    (    char        colr          x   y  sp# )
      [CHAR] A I +   I 3 + 15 AND  100  90 I 8* +  I SPRITE
   LOOP ;

: MOVEALL   0 ?DO   RNDXY I MOTION  20 MS LOOP ;

: SPRITE-CTRL
       PAUSE
       0 TRAP
       0 1 COLLISION
       1 TRAP
       2 TRAP
       3 TRAP
       0 5 COLLISION
       4 TRAP
       5 TRAP
       1 5 COLLISION
       MUTE
       MYSELF SLEEP PAUSE
;

HEX 2000 CONSTANT TASK1

: RUN ( -- )
    1 SCREEN
    1 MAGNIFY
    4 19 16 1 COLORS
    PAGE ." CAMEL99 Forth"
    CR   ." Coincidence Test with Automotion"
    CR
    0 23 AT-XY ." A B and F collide"
    6 DUP SPRITES MOVEALL
    MULTI TASK1 WAKE
    AUTOMOTION
    BEGIN
      PAUSE
      ?TERMINAL
    UNTIL
    STOPMOTION
    8 SCREEN ;

TASK1 USIZE 0 FILL
TASK1 FORK
' SPRITE-CTRL TASK1 ASSIGN

CR .( Type RUN to start demo)
