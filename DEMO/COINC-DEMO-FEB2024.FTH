\ Sprite COINC and TRAP Demo

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RND        FROM DSK1.RANDOM

MARKER /TEST

DECIMAL
: TINK    GEN1  1500 HZ  -6 DB  500 TICKS MUTE ;
: BONK    GEN2   110 HZ  -4 DB  80 MS MUTE ;

: CLIP   ( n lo hi -- n)  ROT MIN MAX ;

\ clip x,y sprite positions to within the 4 walls 
: CLIPX  ( spr# -- ) SP.X  DUP VC@  4 238 CLIP  SWAP VC! ;
: CLIPY  ( spr# -- ) SP.Y  DUP VC@  4 180 CLIP  SWAP VC! ;

: REVERSE ( Vaddr -- ) DUP VC@ NEGATE  SWAP VC! ;

: BOUNCE.X  ( spr# --)  DUP CLIPX  ]SMT.X REVERSE ; 
: BOUNCE.Y  ( spr# --)  DUP CLIPY  ]SMT.Y REVERSE ; 

: BOUNCE    ( spr# --) DUP BOUNCE.X BOUNCE.Y  ;

\ flag=true if x or y are outside limits 
: XLIMIT? ( x -- ?) 239 3 WITHIN ;
: YLIMIT? ( Y -- ?) 182 3 WITHIN ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      XLIMIT? IF  BOUNCE.X  TINK   EXIT 
      THEN  DROP  ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      YLIMIT? IF  BOUNCE.Y  TINK  EXIT 
      THEN  DROP  ;

\ keep a sprite inside 4 walls 
: TRAP ( spr# -- ) DUP TRAPX TRAPY   ;

DECIMAL
: RNDV   ( -- x y)   50 RND 10 + 15 -  ;
: RNDXY  ( -- dx dy)  RNDV RNDV ;

: SPRITES ( -- ) \ makes n sprites
    (    char   colr  x    y  sp#         X/Y  spr#   )
    [CHAR] 0     3   10    90  0 SPRITE  RNDXY  0 MOTION   
    [CHAR] 1     4   20    90  1 SPRITE  RNDXY  1 MOTION  
    [CHAR] 2     5   33    90  2 SPRITE  RNDXY  2 MOTION  
    [CHAR] 3     6   56    90  3 SPRITE  RNDXY  3 MOTION  
    [CHAR] 4     7   125   90  4 SPRITE  RNDXY  4 MOTION  
    [CHAR] 5     8   200   90  5 SPRITE  RNDXY  5 MOTION  
\    [CHAR] A     9   10   190  6 SPRITE  RNDXY  6 MOTION   
\    [CHAR] B    10   20   140  7 SPRITE  RNDXY  7 MOTION  
\    [CHAR] C    11   33   130  8 SPRITE  RNDXY  8 MOTION  
\    [CHAR] D    12   56   120  9 SPRITE  RNDXY  9 MOTION  
;

\ test sprite collision 
: BUMP ( SPR# SPR# -- ) 
  2DUP 10 COINC IF  BOUNCE BOUNCE BONK  EXIT THEN 
  2DROP   \ no coincidence, just drop the args
; 

: COLLISIONS 
    0 TRAP  
     COINCALL IF 1 0 BUMP  THEN 
    1 TRAP   
    COINCALL IF  2 0 BUMP  THEN 
    2 TRAP  
    COINCALL IF  1 2 BUMP  THEN 
    3 TRAP  
    4 TRAP  \ COINCALL IF  2 4 BUMP           THEN 
    5 TRAP  \ COINCALL IF  5 4 BUMP  5 0 BUMP THEN 
 \   6 TRAP 
 \   7 TRAP
 \   8 TRAP
 \   9 TRAP 
;    

: RUN ( -- )
    DELALL 
    2 SCREEN
    1 MAGNIFY
    4 19  16 1 COLORS 
    PAGE ." CAMEL99 Forth Sprite Automotion"
    CR   ." Trap All. Coinc 0 1 & 2"
    CR
    SPRITES
    AUTOMOTION
    BEGIN
        COLLISIONS 
        ?TERMINAL
    UNTIL
    STOPMOTION
    DELALL
    4 19  2 1 COLORS 
    8 SCREEN ;

CR .( Type RUN to start demo)
