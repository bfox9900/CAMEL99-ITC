\ Sprite COINC and TRAP Demo    oCT 13 2025

\ This demo uses a task to control automotion.
\ Automotion becomes "cooperative" and so the
\ coincidence detection never misses.

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RND        FROM DSK1.RANDOM
NEEDS MULTI      FROM DSK1.MTASK99
NEEDS MALLOC     FROM DSK1.MALLOC


MARKER /TEST

\ create a task in heap, fork it, assign Execution token and run it
HEX
: RESET-HEAP    2000 H ! ;

: SPAWN  ( xt -- ) USIZE MALLOC DUP >R FORK  R@ ASSIGN  R> WAKE ;

HEX
CODE 0LIMI   0300 , 0000 ,  NEXT, ENDCODE
CODE 2LIMI   0300 , 0002 ,  NEXT, ENDCODE

\ stop interrupts during sound duration time
: MS    0LIMI   MS   2LIMI  ;

: VC1+! ( Vaddr -- ) DUP VC@ 1+ SWAP VC! ;

DECIMAL
: TINK    GEN1  1500 HZ  -6 DB  30 MS MUTE ;
: BONK    GEN2   110 HZ  -4 DB  80 MS MUTE ;

: CLIP   ( n lo hi -- n) S" ROT MIN MAX" EVALUATE ; IMMEDIATE

\ clip x,y sprite positions to within the 4 walls
: CLIPX  ( spr# -- ) SP.X  DUP VC@  4 238 CLIP  SWAP VC! ;
: CLIPY  ( spr# -- ) SP.Y  DUP VC@  4 180 CLIP  SWAP VC! ;

: REVERSE ( Vaddr -- ) DUP VC@ NEGATE  SWAP VC! ;

: BOUNCE.X  ( spr# --)  DUP CLIPX  ]SMT.X REVERSE ;
: BOUNCE.Y  ( spr# --)  DUP CLIPY  ]SMT.Y REVERSE ;

: BOUNCE    ( spr# --)  DUP BOUNCE.X DUP BOUNCE.Y ;

\ flag=true if x or y are outside limits
: XLIMIT? ( x -- ?) 239 3 WITHIN ;
: YLIMIT? ( Y -- ?) 182 3 WITHIN ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      XLIMIT? IF  BOUNCE.X   TINK EXIT THEN
      DROP  ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      YLIMIT? IF  BOUNCE.Y   TINK  EXIT THEN
      DROP  ;

DECIMAL
: RNDV   ( -- x y)   46 RND 23 -  ;
: RND-DXDY  ( -- dx dy)  RNDV RNDV ;

HEX
CREATE PAT127 3C42 , A581 , A599 , 423C ,

DECIMAL
: SPRITES ( -- ) \ makes n sprites
    ( char      colr  x    y  sp#         X/Y  spr#   )
      127       11   10    90  0 SPRITE RND-DXDY  0 MOTION
    [CHAR] 1     3   20    90  1 SPRITE RND-DXDY  1 MOTION
    [CHAR] 2     3   33    90  2 SPRITE RND-DXDY  2 MOTION
    [CHAR] 3     3   56    90  3 SPRITE RND-DXDY  3 MOTION
    [CHAR] 4     3   125   90  4 SPRITE RND-DXDY  4 MOTION
    [CHAR] 5     3   200   90  5 SPRITE RND-DXDY  5 MOTION
    [CHAR] 6     3   10   190  6 SPRITE RND-DXDY  6 MOTION
    [CHAR] 7     3   20   140  7 SPRITE RND-DXDY  7 MOTION
\    [CHAR] 8    11   33   130  8 SPRITE D DRND-DXDY  8 MOTION
\    [CHAR] 9    12   56   120  9 SPRITE D DRND-DXDY  9 MOTION
;


\ test sprite coincidence and bounce if detected
: ?BUMP ( SPR# SPR# -- )
    2DUP 9 COINC
    IF
       BOUNCE
       BONK
       EXIT
    THEN
    2DROP   \ no coincidence, just drop the args
;

\ =================  COINCIDENCE TASKS ===============
\ Tasks run in an endless loop
: COLLIDER
        COINCALL IF   1 0 ?BUMP   THEN
        COINCALL IF   2 0 ?BUMP   THEN
        COINCALL IF   3 0 ?BUMP   THEN
        COINCALL IF   4 0 ?BUMP   THEN
        COINCALL IF   5 0 ?BUMP   THEN
;

DECIMAL
: TRAPPER   SPR# @ 1+ 0 DO  I DUP TRAPX TRAPY  LOOP ;

DECIMAL
: RUN ( -- )
    RESET-HEAP
    DELALL
    PAT127 127 CHARDEF
    2 SCREEN
    1 MAGNIFY
    4 19  16 1 COLORS
    PAGE ." CAMEL99 Forth Sprite Automotion"
    CR   ." Trap All. Coinc 0 with 1..5"
    CR
    SPRITES
\    MULTI
    AUTOMOTION
    BEGIN
        0LIMI
        COLLIDER TRAPPER
        2LIMI

        ?TERMINAL
    UNTIL
    STOPMOTION
\    SINGLE
    SILENT
    DELALL
    4 19  2 1 COLORS
    8 SCREEN ;

CR .( Type RUN to start demo)
