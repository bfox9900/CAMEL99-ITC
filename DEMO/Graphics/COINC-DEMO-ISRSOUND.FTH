\ Sprite COINC and TRAP Demo

\ Notes:
\ A problem with testing coincidence and starting a sound
\ is the the sound duration is a loop running in the main program.
\ This means the program cannot test for coincidence while waiting
\ for the sound duration to expire.

\ This version uses the TI-99 ROM based sound player which runs
\ under interrupt control. Essentially a background task.

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RND        FROM DSK1.RANDOM
NEEDS VBYTE      FROM DSK1.ISRSOUND

MARKER /TEST
HEX
CODE 0LIMI   0300 , 0000 ,  NEXT, ENDCODE
CODE 2LIMI   0300 , 0002 ,  NEXT, ENDCODE

\ SOUND COMPILERS, put data VDP memory to build sound lists
DECIMAL
: HZ,     ( f -- )     (HZ) SPLIT VC, VC,   ;
: DB,     ( level -- ) (DB) VC,  ;
: MUTE,   ( -- )       -30 DB,   ;
: MS,     ( n -- )     4 RSHIFT  VC, ;  \ ms/16 = 1/60

\ compile bytes to turn all sound off
HEX
\ noise channel selects generator 4 by default
: NOISE,  ( n -- )  0F AND  GEN4 OSC @ OR  VC,  ;

DECIMAL
\ create a named sound list in VDP RAM that plays when executed
: SOUND: ( <text> -- ) CREATE  VHERE ,   !CSP  DOES> @ ISRPLAY ;
: ;SOUND ( -- )  0 VC,  ?CSP ;

\ start/end a VDP byte string.
: $[     ( -- vaddr)   VHERE 0 VC, ;
: ]$     ( vaddr -- )  VHERE OVER - 1- SWAP VC! ;

\ end a sound string with a duration. Stores duration at end
: MS]     ( vaddr dur -- ) SWAP ]$   MS, ;
: [MUTE]      $[ MUTE, ]$ ;

SOUND: TINK  $[ GEN1 1500 HZ,  -6 DB,  20 MS] [MUTE] ;SOUND
SOUND: BONK  $[ GEN2  110 HZ   -4 DB,  80 MS] [MUTE] ;SOUND

: CLIP   ( n lo hi -- n) S" ROT MIN MAX" EVALUATE ; IMMEDIATE

\ clip x,y sprite positions to within the 4 walls
: CLIPX  ( spr# -- ) SP.X  DUP VC@  4 238 CLIP  SWAP VC! ;
: CLIPY  ( spr# -- ) SP.Y  DUP VC@  4 180 CLIP  SWAP VC! ;

: REVERSE ( Vaddr -- ) DUP VC@ NEGATE  SWAP VC! ;

: BOUNCE.X  ( spr# --)  DUP CLIPX  ]SMT.X REVERSE ;
: BOUNCE.Y  ( spr# --)  DUP CLIPY  ]SMT.Y REVERSE ;

: BOUNCE    ( spr# --) DUP BOUNCE.X BOUNCE.Y  ;

\ flag=true if x or y are outside limits
: XLIMIT? ( x -- ?) 245 8 WITHIN ;
: YLIMIT? ( Y -- ?) 182 8 WITHIN ;

: TRAPX ( spr# -- )
      DUP SP.X VC@
      XLIMIT? IF  BOUNCE.X  TINK EXIT THEN
      DROP  ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@
      YLIMIT? IF  BOUNCE.Y  TINK  EXIT THEN
      DROP  ;

\ keep a sprite inside 4 walls
: TRAP ( spr# -- ) S" DUP TRAPX TRAPY" EVALUATE ; IMMEDIATE

DECIMAL
: RNDSPEED   ( -- x y) 70 RND 35 -  ;
: RNDX   ( -- x) 240 RND 15 + ;
: RNDY   ( -- y) 185 RND 12 + ;

: RND-DXY  ( -- dx dy) \ dx dy are never zero
    BEGIN RNDSPEED ?DUP UNTIL
    BEGIN RNDSPEED ?DUP UNTIL ;

HEX
CREATE HAPPY 3C42 , A581 , A599 , 423C ,

DECIMAL
: SPRITES ( -- ) \ makes n sprites
    ( char      colr  x    y  sp#         X/Y  spr#   )
      127       11   10    90  0 SPRITE  RND-DXY  0 MOTION
    27 1
    DO
        I [CHAR] A +  I 2 + 3 MAX  RNDX RNDY  I SPRITE
        RND-DXY I MOTION
    LOOP
;

\ test sprite coincidence and bounce if detected
: ?BUMP ( SPR# SPR# -- )
  2DUP 10 COINC IF  BOUNCE BOUNCE BONK  EXIT THEN
  2DROP   \ no coincidence, just drop the args
;

\ Putting coicidence code in a DO LOOP is slower
\ than "unwinding" the loop as separate lines of code
: TRAPPER
    0LIMI
    SPR# @ 1+ 0 DO I TRAP  LOOP ;
    2LIMI
;

: RUN ( -- )
    DELALL
    HAPPY 127 CHARDEF
    2 SCREEN
    1 MAGNIFY
    4 19  16 1 COLORS
    PAGE ." CAMEL99 Forth Sprite Automotion"
    CR 5 SPACES  ." >> Using ISR sound <<"
    CR
    SPRITES
    AUTOMOTION
    BEGIN
        TRAPPER
        ?TERMINAL
    UNTIL
    STOPMOTION
    DELALL
    4 19  2 1 COLORS
    8 SCREEN ;

CR .( Type RUN to start demo)
