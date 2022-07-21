\ Sprite COINC and COINCY DEMO      July 2021  Brian Fox
\ Things to notice:
\ BOUNCE.X  BOUNCE.Y reverse the motion of a sprite by directly reading the
\ SPRITE motion table in VDP RAM. The array is called ]SMT.
\ **remember to use VDP char fetch/store operations   VC@  VC!

\ TRAP.X TRAP.Y  let you read or write test sprite position in X and Y
\ independantly using SP.X  and SP.X. Also use VC@  VC! for these data points.

\ EXIT THEN  is like a GOTO semi-colon.  Allows faster escape after IF

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS RND        FROM DSK1.RANDOM
NEEDS MARKER     FROM DSK1.MARKER

MARKER /TEST
DECIMAL
168 CONSTANT BRICK

\ define chars
S" 00FEFEFEFEFEFEFE"  BRICK CALLCHAR
BRICK  SET#  7 15 COLOR

: .BORDER   ( -- )
  \ col row
     0   1 BRICK 32 HCHAR
     0  23 BRICK 32 HCHAR
     0   1 BRICK 23 VCHAR
    31   1 BRICK 23 VCHAR ;

DECIMAL
: TINK   ( spr# ) GEN1 >< 1200 +  HZ -4 DB  ;
: THUMP  ( -- )   GEN1  150 HZ  0 DB  20 MS  MUTE  ;

: SP.STOP   ( spr# ) 0 0 ROT MOTION ;
: BOUNCE.X  ( spr# -- ) ]SMT.X DUP VC@ NEGATE  SWAP VC! 30 MS ;
: BOUNCE.Y  ( spr# -- ) ]SMT.Y DUP VC@ NEGATE  SWAP VC! 30 MS ;

: HLIMIT?  ( X -- ?)  235  7 WITHIN ; \ true if outside limits
: VLIMIT?  ( Y -- ?)  170 15 WITHIN ; \ true if outside limits

: REVERSE   ( spr# -- )  DUP BOUNCE.X   BOUNCE.Y  ;

: TRAP.X ( spr# -- )
      DUP
      SP.X VC@ HLIMIT?
      IF DUP BOUNCE.X  EXIT
      THEN DROP ;

: TRAP.Y ( spr# -- )
      DUP
      SP.Y VC@ VLIMIT?
      IF DUP  BOUNCE.Y  EXIT
      THEN DROP ;

: TRAP  ( spr# -- )
        DUP TRAP.X TRAP.Y  ;

: RAINBOW  ( spr# -- )
       DUP SP.COLR VC@ SWAP
       16 2
       DO
          I OVER SP.COLOR
          25 MS
          2 TRAP   \ keep the other guys trapped
          GEN2 I DB   \ FADE the sound down
       LOOP
       SP.COLR VC!
       MUTE ;

: COLLISION ( spr1 spr2 -- )
      2DUP 4 COINC  \ 4 is tolerance in pixels
      IF
         DUP REVERSE OVER REVERSE
         ( spr1 spr2) THUMP
         DUP RAINBOW DROP
         EXIT
      THEN  2DROP ;

: MAKE-SPRITES
 ( char     colr  x   y  sp# )
   [CHAR] @   7   90 100  0 SPRITE  31 28 0 MOTION
   [CHAR] #   3  200 100  1 SPRITE  26 26 1 MOTION
   [CHAR] Q   6  150 100  2 SPRITE  29 32 2 MOTION
;

DECIMAL
: RUN ( motionx motiony -- )
    PAGE ." CAMEL99 Forth Coicidence Test"
    11 SCREEN
    .BORDER
    4 4 AT-XY ." '#' and '@' will collide"
    MAKE-SPRITES
       1 MAGNIFY
       AUTOMOTION
\ polling loop for collisions and walls
       BEGIN
           0 TRAP
           0 1 7 COINC IF 1 REVERSE 0 REVERSE THUMP THEN
           1 TRAP
           0 2 7 COINC IF 2 REVERSE 0 REVERSE THUMP THEN
           2 TRAP
           1 2 7 COINC IF 1 REVERSE 2 REVERSE THUMP THEN
          ?TERMINAL
       UNTIL
       STOPMOTION  ;
