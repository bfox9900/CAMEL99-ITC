\ SPITE COINDENCE DEMO FOR CAMEL99 FORTH for the TI-99 Computer

INCLUDE DSK1.TOOLS
INCLUDE DSK1.DIRSPRIT   \ this also loads GRAFIX.F
INCLUDE DSK1.RANDOM


\ happy face in 4 pieces
HEX
071F 3F7F 7FFB FFFF PATTERN: TOPLEFT
FFFF F778 7F3F 1F07 PATTERN: BOTLEFT
E0F8 FCFE FEDF FFFF PATTERN: TOPRIGHT
FFFF EF1E FEFC F8E0 PATTERN: BOTRIGHT

DECIMAL
\ GENERATE random motion vectors
: RNDXY  ( -- dx dy ) 5 RND 2-   5  RND 2- ;

\ create some motion vectors as double variables (2 cells)
\ use 2@ and 2! on them
CREATE V0   -1 ,  1 ,    \ each sprite needs its own vector
CREATE V1    1 ,  0 ,

: .VECTORS
         0 0 CLRLN  V1 2@  . . ;

: NEWVECTORS
          RNDXY  V0 2!
          RNDXY  V1 2!
          .VECTORS ;

\ Usage:  V1 REVERSE
: REVERSE ( motion-vector-addr -- )
          DUP 2@ NEGATE SWAP NEGATE SWAP ROT 2! ;

: SP.POS+ ( dx dy spr# -- )  \ add dx dy sprite's position
          DUP >R  SP.Y@ + R@ SP.Y!
              R@ SP.X@ + R> SP.X! ;

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

\      [CHAR] w    9   10  90   5   SPRITE
\      [CHAR] w    9  125  90   6   SPRITE
\      [CHAR] w    9  220  90   7   SPRITE

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
           V1 REVERSE
           HONK
           20 1
           DO I 1 SP.COLOR
              (MOVE#1)
              5 JIFFS
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
       8 SPEED !
       BEGIN
         NEWVECTORS
         800 RND 100 + 0
         DO
           MOVE#1
           COINCALL
           IF
              BOUNCE
           THEN
         LOOP
         ?TERMINAL ABORT" HALTED"
       AGAIN ;
