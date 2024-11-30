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
: BOUNCE.X  ( spr# -- ) ]SMT.X  DUP VC@ NEGATE  SWAP VC! PAUSE ;
: BOUNCE.Y  ( spr# -- ) ]SMT.Y  DUP VC@ NEGATE  SWAP VC! PAUSE ;

: BOUNCE    ( spr# -- ) DUP BOUNCE.X BOUNCE.Y  ; \ multi-task version


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
HEX 2000 CONSTANT TASK1

\ ADD pause to I/O functions for smooth multi-tasking
: TINK  ( -- )  GEN1 1600 HZ -6 DB  PAUSE ; \ sound chip I/O

: TRAPX ( spr# -- )
      DUP SP.X VC@ 230 4 WITHIN 
      IF  BOUNCE.X  TINK   EXIT THEN 
      DROP  PAUSE ;

: TRAPY ( spr# -- )
      DUP SP.Y VC@ 
      170 4 WITHIN 
      IF   BOUNCE.Y  TINK   EXIT THEN
      DROP  PAUSE ;

\ Now it's multi-task friendly
: SP.TRAP ( spr#)  DUP TRAPX TRAPY  ;


: COLLISION ( spr1 spr2 -- )
        2DUP 9 COINC  \ VDP I/O
        IF   
    ( spr2)  BOUNCE 
    ( spr1)  BOUNCE 
             THUMP 400 TICKS 
             GEN2 MUTE
             EXIT
        THEN
        2DROP
;

\ COLLIDER TASK test collisions for all sprites 
\ Notice it's an endless loop
DECIMAL
: COLLIDER ( spr# -- )
    HEX
    BEGIN
      6 0 DO 
        6 0 DO 
             I J COLLISION 
             PAUSE
        LOOP 
      LOOP 
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
   TASK1 DUP USIZE 0 FILL  FORK
    ['] COLLIDER TASK1 ASSIGN
    MULTI 
\    TASK1 WAKE
    AUTOMOTION
    BEGIN
       0 SP.TRAP
       1 SP.TRAP
       2 SP.TRAP
       3 SP.TRAP
       4 SP.TRAP
       5 SP.TRAP
       SILENT 
       ?TERMINAL
   UNTIL
   SINGLE
   STOPMOTION
   8 SCREEN ;


\    MULTI  TRAPPER WAKE

CR .( Type RUN to start demo)
