\ Manual sprite motion with coincidence detection  B Fox Aug 9 2020
\ SEE: DSK1.MOTION  for tools to assist with more sprites

\ NEEDS DUMP   FROM DSK1.TOOLS    \ for debugging only
NEEDS RND      FROM DSK1.RANDOM
NEEDS SPRITE FROM DSK1.DIRSPRIT   \ also loads DSK1.GRAFIX

\ happy face in 4 pieces
HEX
CREATE TOPLEFT  071F , 3F7F , 7FFB , FFFF ,
CREATE BOTLEFT  FFFF , F778 , 7F3F , 1F07 ,
CREATE TOPRIGHT E0F8 , FCFE , FEDF , FFFF ,
CREATE BOTRIGHT FFFF , EF1E , FEFC , F8E0 ,

DECIMAL
\ GENERATE random motion vectors
: RNDXY  ( -- dx dy ) 3 RND 1-   3  RND 1- ;

\ create some motion vectors as double variables (2 cells)
\ use 2@ and 2! on them
CREATE V0   -1 ,  1 ,    \ each sprite needs its own vector
CREATE V1    1 ,  0 ,

: CLRLINE ( col row --) AT-XY  VPOS C/L@  BL VFILL ;

: .VECTORS
         0 0 CLRLINE  V1 2@  . . ;

: NEWVECTORS
          RNDXY  V0 2!
          RNDXY  V1 2!
          .VECTORS ;

\ Usage:  V1 REVERSE
: REVERSE ( motion-vector-addr -- )
          DUP 2@ NEGATE SWAP NEGATE SWAP ROT 2! ;

: SP.POS+ ( dx dy spr# -- )  \ add dx dy to sprite's position
          DUP >R SP.Y VC@ + R@ SP.Y VC!
              R@ SP.X VC@ + R> SP.X VC! ;

: MAKE-FACE
      TOPLEFT   [CHAR] t CHARDEF
      BOTLEFT   [CHAR] u CHARDEF
      TOPRIGHT  [CHAR] v CHARDEF
      BOTRIGHT  [CHAR] w CHARDEF ;

: MAKE-SPRITES ( -- )
      \ Ptrn    clr col  row  spr#
      \ ------  --- ---  ---  ----
  \    [CHAR] w   16  150  80   0   SPRITE   \ the only white sprite
       [CHAR] w   11   20  80   1   SPRITE
       [CHAR] w    9   10  16   2   SPRITE
       [CHAR] w    9  125  16   3   SPRITE
       [CHAR] w    9  220  16   4   SPRITE

      [CHAR] w    9   10  90   5   SPRITE
      [CHAR] w    9  125  90   6   SPRITE
      [CHAR] w    9  220  90   7   SPRITE

      [CHAR] w    9   10  170  8   SPRITE
      [CHAR] w    9  125  170  9   SPRITE
      [CHAR] w    9  220  170 10   SPRITE  ;

\ Speed control example.
VARIABLE SPEED

: (MOVE#1)    V1 2@  1 SP.POS+ ;

: MOVE#1  ( -- )
\ each time this word is called we
\ 1. DECREMENT the speed variable
\ 2. check if speed=0
\ 3. if speed=0 then move the sprite and reset the speed variable
           -1 SPEED +!
           SPEED @ 0=
           IF                    \ when it hits 0 move sprite
               (MOVE#1)
               8 SPEED !         \ reset the speed counter
           THEN ;

: BOUNCE ( -- )  \ bounce off each other
           HONK
           V1 REVERSE
           17 1
           DO I 1 SP.COLOR
              (MOVE#1)
              5 TICKS
           LOOP
           11 1 SP.COLOR ;

\ 2 sprites move in random directions
\ Sprite #0 changes color if it collides
: RUN
       PAGE
       13 SCREEN
       2 MAGNIFY
       MAKE-FACE
       MAKE-SPRITES
       4 SPEED !
       BEGIN
         NEWVECTORS
         2000 RND 300 + 0
         DO
           MOVE#1
           COINCALL
           IF
              BOUNCE
           THEN
         LOOP
         ?TERMINAL ABORT" HALTED"
       AGAIN ;
