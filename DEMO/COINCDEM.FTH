INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.DIRSPRIT.F   \ this also loads GRAFIX.F
INCLUDE DSK1.RANDOM.F

\ happy face in 4 pieces
HEX
071F 3F7F 7FFB FFFF PATTERN: TOPLEFT
FFFF F778 7F3F 1F07 PATTERN: BOTLEFT
E0F8 FCFE FEDF FFFF PATTERN: TOPRIGHT
FFFF EF1E FEFC F8E0 PATTERN: BOTRIGHT

DECIMAL
\ GENERATE random motion vectors
: RNDXY  ( -- dx dy ) 3 RND 1-   3  RND 1- ;

\ create some motion vectors as double variables (2 cells)
\ use 2@ and 2! on them
CREATE V0   -1 ,  1 ,    \ each sprite needs its own vector
CREATE V1    1 ,  0 ,

: .VECTORS
          V0 2@  0 0 AT-XY . .
          V1 2@ 26 0 AT-XY . . ;

: NEWVECTORS
          RNDXY  V0 2!
          RNDXY  V1 2!
          .VECTORS ;

\ Usage:  V1 REVERSE
: REVERSE ( motion-vector-addr -- )
          DUP 2@ NEGATE SWAP NEGATE SWAP ROT 2! ;

: SP.MOVE ( dx dy spr# -- )  \ move sprite by vector dx dy
          DUP >R SP.Y@ + R@ SP.Y!
              R@ SP.X@ + R> SP.X! ;

: MAKE-FACE
      TOPLEFT   [CHAR] t CHARDEF
      BOTLEFT   [CHAR] u CHARDEF
      TOPRIGHT  [CHAR] v CHARDEF
      BOTRIGHT  [CHAR] w CHARDEF ;

: MAKE-SPRITES ( -- )
      \ Ptrn    clr col  row  spr#
      \ ------  --- ---  ---  ----
      [CHAR] w   16  150  80   0   SPRITE   \ the only white sprite
      [CHAR] w   11   20  80   1   SPRITE ;

\ Speed control example.
VARIABLE SPEED   5 SPEED !

: MOVE#1  ( -- )
\ each time this word is called we
\ 1. DECREMENT the speed variable
\ 2. check if speed=0
\ 3. if speed=0 then move the sprite and reset the speed variable
           -1 SPEED +!
           SPEED @ 0=
           IF                    \ when it hits 0 move sprite
               V1 2@ 1 SP.MOVE
               5 SPEED !         \ reset the speed counter
           THEN ;

: MOVE-EVERYBODY ( -- ) \ fetch
          V0 2@ 0 SP.MOVE                                               
          MOVE#1 ;

: BOUNCE ( -- )  \ bounce off each other
           7 1 SP.COLOR
           V0 REVERSE
           V1 REVERSE
           50 0 DO
              V0 2@ 0 SP.MOVE
              V1 2@ 1 SP.MOVE
              40 MS
           LOOP
           11 1 SP.COLOR
           NEWVECTORS ;

\ 2 sprites move in random directions
\ Sprite #0 changes color if it collides
: RUN
       PAGE
       13 SCREEN
       2 MAGNIFY
       MAKE-FACE
       MAKE-SPRITES
       BEGIN
        400 0 
        DO
          MOVE-EVERYBODY
          COINCALL IF  BOUNCE  THEN
          ?BREAK
        LOOP
        NEWVECTORS
      AGAIN ;

