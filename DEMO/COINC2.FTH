\ Sprite COINC and COINCY Test

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RNDV       FROM DSK1.RANDOM

MARKER /TEST

DECIMAL
: TINK    GEN1 1600 HZ -6 DB 12 MS MUTE ;
: THUMP   GEN2  150 HZ  0 DB  ;

: BOUNCE.X  ( spr# -- ) ]SMT.X  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE.Y  ( spr# -- ) ]SMT.Y  DUP VC@ NEGATE  SWAP VC! ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      239 0 WITHIN IF   BOUNCE.X   EXIT THEN
      DROP ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      185 0 WITHIN IF  BOUNCE.Y TINK EXIT THEN
      DROP ;

: TRAP ( spr# -- ) DUP TRAPX TRAPY ;

: RAINBOW  ( spr# -- )
       THUMP
       16 3
       DO
          I OVER SP.COLOR
          25 MS
          1 TRAP 2 TRAP   \ keep the other guys trapped
          GEN2 I DB       \ FADE the sound down
       LOOP
       DROP MUTE ;

: SP.STOP  ( spr# ) 0 0 ROT MOTION ;

: COLLISION ( spr1 spr2 -- )
        2DUP 1 COINC
        IF
    ( spr2)  DUP BOUNCE.X BOUNCE.Y
    ( spr1)  DUP SP.STOP                \ stop the sprite 1
             DUP BOUNCE.X DUP BOUNCE.Y
             DUP RAINBOW        \ show his displeasure :)
             15 15 ROT MOTION   \ start up again
        ELSE
              2DROP
        THEN ;


DECIMAL
: RNDV ( -- x y) 50 RND 25 -  ;
: RNDXY    RNDV RNDV ;

: SPRITES ( n -- )
    0 ?DO
    (    char        colr          x   y  sp# )
      [CHAR] @ I +   I 1+ 15 AND  100  90  I SPRITE
   LOOP ;

: MOVEALL   0 ?DO   RNDXY I MOTION  20 MS LOOP ;

: RUN ( -- )
    1 SCREEN
    1 MAGNIFY
    PAGE ." CAMEL99 Forth"
    CR   ." Coincidence Test with Automotion"
    CR
    CR   ." '#' and '@' will collide"
    15 DUP SPRITES MOVEALL
    AUTOMOTION
    BEGIN
         0 TRAP  1 TRAP  2 TRAP  3 TRAP  4 TRAP   5 TRAP
         6 TRAP  7 TRAP  8 TRAP  9 TRAP 10 TRAP  11 TRAP
        12 TRAP 13 TRAP 14 TRAP
         ?TERMINAL
   UNTIL
   STOPMOTION
   8 SCREEN ;

CR .( Type RUN to start demo)
