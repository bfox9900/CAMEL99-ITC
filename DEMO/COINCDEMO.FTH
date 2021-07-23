\ Sprite COINC and COINCY DEMO      July 2021  Brian Fox
\ Things to notice:
\ BOUNCE.X  BOUNCE.Y reverse the motion of a sprite by directly reading the
\ SPRITE motion table in VDP RAM. The array is called ]SMT.
\ **remember to use VDP char fetch/store operations   VC@  VC!

\ TRAP.X TRAP.Y  let you read or write test sprite position in X and Y
\ independantly using SP.X  and SP.X. Also use VC@  VC! for these data points.

\ EXIT THEN  is like a GOTO semi-colon.  Allows faster escape after IF

\ NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND

MARKER /TEST

DECIMAL
: TINK   ( spr# ) GEN1 >< 1500 +  HZ -6 DB 20 MS MUTE ;
: THUMP   GEN2  150 HZ  0 DB  ;

: SP.STOP  ( spr# ) 0 0 ROT MOTION ;

: BOUNCE.X  ( spr# -- ) ]SMT 1+ DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE.Y  ( spr# -- ) ]SMT    DUP VC@ NEGATE  SWAP VC! ;
: REVERSE   ( spr# -- )  DUP BOUNCE.X   BOUNCE.Y ;

: TRAP.X ( spr# -- )
      DUP SP.X VC@
      242 0 WITHIN
      IF DUP BOUNCE.X  TINK  EXIT
      THEN DROP ;

: TRAP.Y ( spr# -- )
      DUP SP.Y VC@ 185 0 WITHIN
      IF DUP  BOUNCE.Y TINK  EXIT
      THEN DROP ;

: TRAP  ( spr# -- ) DUP TRAP.X TRAP.Y ;

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


: COLLISION ( spr1 spr2 -- )
        2DUP 9 COINC  \ 9 is tolerance in pixels
        IF
    ( spr1 spr2) DUP REVERSE OVER REVERSE
                 DUP RAINBOW DROP \ show displeasure :)
        ELSE
             2DROP
        THEN ;

DECIMAL
: RUN ( motionx motiony -- )
    7 SCREEN
    PAGE ." CAMEL99 Forth"
    CR   ." Coincidence Test with Automotion"
    CR
    CR   ." '#' and '@' will collide"
 ( char     colr  x   y  sp# )
   [CHAR] @  16   90 100  0 SPRITE  35 36 0 MOTION
   [CHAR] #   3  200 100  1 SPRITE  36 35 1 MOTION
   [CHAR] Q   8  200 100  2 SPRITE  29 32 2 MOTION

       1 MAGNIFY
       AUTOMOTION
\ polling loop for collisions and walls
       BEGIN
           0 TRAP
         0 1 COLLISION
           1 TRAP
         0 1 COLLISION
           2 TRAP
         0 1 COLLISION
        ?TERMINAL
       UNTIL
       STOPMOTION  ;

CR .( Type RUN to start demo)
