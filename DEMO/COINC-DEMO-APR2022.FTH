\ Sprite COINC and TRAP Demo

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RND        FROM DSK1.RANDOM

MARKER /TEST

DECIMAL
: BOUNCE.X  ( spr# --) ]SMT.X  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE.Y  ( spr# --) ]SMT.Y  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE    ( spr# --) DUP BOUNCE.X BOUNCE.Y  ;


: TINK    GEN1  1500 HZ  -6 DB  1500 TICKS  ;
: BONK    GEN2  110 HZ    0 DB  150 MS MUTE ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      239 0 WITHIN IF   BOUNCE.X  TINK EXIT THEN
      MUTE DROP  ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      185 0 WITHIN IF  BOUNCE.Y   TINK  EXIT THEN
      MUTE DROP  ;

: TRAP ( spr# -- ) DUP TRAPX TRAPY   ;

DECIMAL
: RNDV   ( -- x y)   50 RND 15 + 25 -  ;
: RNDXY  ( -- dx dy)  RNDV RNDV ;

: SPRITES ( n -- ) \ makes n sprites
    (    char   colr  x   y  sp#         X/Y  spr#   )
    [CHAR] 0     3   100  90  0 SPRITE  RNDXY  0 MOTION 100 MS 
    [CHAR] 1     5   100  90  1 SPRITE  RNDXY  1 MOTION 100 MS
    [CHAR] 2     7   100  90  2 SPRITE  RNDXY  2 MOTION 100 MS
    [CHAR] 3    11   100  90  3 SPRITE  RNDXY  3 MOTION 100 MS
    [CHAR] 4    16   100  90  4 SPRITE  RNDXY  4 MOTION 100 MS
    [CHAR] 5     6   100  90  5 SPRITE  RNDXY  5 MOTION 100 MS
;

\ test sprite collision 
: BUMP ( SPR# SPR# -- ) 
  2DUP 10 COINC 
  IF  BOUNCE BOUNCE BONK  
  ELSE 2DROP   \ no coincidence, just drop the args
  THEN ; 

: RUN ( -- )
    2 SCREEN
    1 MAGNIFY
    PAGE ." CAMEL99 Forth"
    CR   ." Trap/Coinc Test with Automotion"
    CR
    SPRITES

    AUTOMOTION
    BEGIN
         0 TRAP
         1 0 BUMP 
         1 TRAP
         0 2 BUMP 
         2 TRAP
         1 2 BUMP 
           3 TRAP
         3 2 BUMP
         4 TRAP
         3 0 BUMP
         4 2 BUMP 
         5 TRAP
         ?TERMINAL
    UNTIL
    STOPMOTION
\    DELALL
    8 SCREEN ;

CR .( Type RUN to start demo)
