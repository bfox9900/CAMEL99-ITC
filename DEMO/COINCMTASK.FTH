\ Using a Task to TRAP sprites

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS SPRITE     FROM DSK1.DIRSPRIT
NEEDS AUTOMOTION FROM DSK1.AUTOMOTION
NEEDS HZ         FROM DSK1.SOUND
NEEDS MARKER     FROM DSK1.MARKER
NEEDS RNDV       FROM DSK1.RANDOM
NEEDS TASK       FROM DSK1.MTASK99

MARKER /TEST

DECIMAL
: SP.STOP  ( spr# ) 0 0 ROT MOTION ;

: THUMP   GEN2  150 HZ  0 DB  ;

\ Add PAUSE to I/O functions for smooth multi-tasking
: BOUNCE.X  ( spr# -- ) PAUSE  ]SMT.X  DUP VC@ NEGATE  SWAP VC! ;
: BOUNCE.Y  ( spr# -- ) PAUSE  ]SMT.Y  DUP VC@ NEGATE  SWAP VC! ;

: BOUNCE    ( spr# -- ) DUP BOUNCE.X BOUNCE.Y  ; \ multi-task version

: COLLISION ( spr1 spr2 -- )
        PAUSE
        2DUP 9 COINC  \ VDP I/O
        IF   THUMP
    ( spr2)  BOUNCE
    ( spr1)  BOUNCE
             GEN2 MUTE
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

\ create workspace for the task in low ram
HEX 2000 CONSTANT TRAPPER

\ ADD pause to I/O functions for smooth multi-tasking
: TINK  ( -- ) PAUSE GEN1 1600 HZ -6 DB  ; \ sound chip I/O

: TRAPX ( spr# -- )
      PAUSE
      DUP SP.X VC@ \ VDP I/O
      239 0 WITHIN IF  BOUNCE.X  TINK  EXIT THEN
      DROP ;

: TRAPY ( spr# -- )
      PAUSE
      DUP SP.Y VC@ \ VDP I/O
      185 0 WITHIN IF  BOUNCE.Y  TINK  EXIT THEN
      DROP ;

\ Now it's multi-task friendly
: SP.TRAP ( spr#)  DUP TRAPX TRAPY  ;

\ SPRITE-TRAP is a what the TRAPPER task does.
\ Notice it's an endless loop
DECIMAL
: SPRITE-TRAP ( spr# -- )
    BEGIN
      0 SP.TRAP
      1 SP.TRAP
      2 SP.TRAP
      3 SP.TRAP
      4 SP.TRAP
      5 SP.TRAP
      GEN1 MUTE
    AGAIN
;

: RUN ( -- )
    1 SCREEN
    1 MAGNIFY
    4 19 16 1 COLORS
    PAGE ." CAMEL99 Forth"
    CR   ." Coincidence Test with Automotion"
    CR
    0 23 AT-XY ." A B and F collide"
    6 DUP SPRITES MOVEALL
    AUTOMOTION
    BEGIN
       0 1 COLLISION
       0 5 COLLISION
       1 5 COLLISION
       MUTE
       ?TERMINAL
   UNTIL
   SINGLE
   STOPMOTION
   8 SCREEN ;

    TRAPPER DUP USIZE 0 FILL  FORK
    ' SPRITE-TRAP  TRAPPER ASSIGN
\    MULTI  TRAPPER WAKE

CR .( Type RUN to start demo)
