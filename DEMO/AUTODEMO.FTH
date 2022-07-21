\ Sprite Coincidence with AUTOMOTION   Update Mar 10 2022

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS GRAPHICS  FROM DSK1.GRAFIX
NEEDS SPRITE    FROM DSK1.DIRSPRIT
NEEDS MOTION    FROM DSK1.AUTOMOTION
NEEDS RND       FROM DSK1.RANDOM
NEEDS HZ        FROM DSK1.SOUND
NEEDS .R        FROM DSK1.UDOTR

\ happy face in 4 pieces
HEX
071F 3F7F 7FFB FFFF PATTERN: TOPLEFT
FFFF F778 7F3F 1F07 PATTERN: BOTLEFT
E0F8 FCFE FEDF FFFF PATTERN: TOPRIGHT
FFFF EF1E FEFC F8E0 PATTERN: BOTRIGHT


 \ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

1 ENUM TRANS
  ENUM BLACK
  ENUM MEDGRN
  ENUM LTGRN
  ENUM DKBLU
  ENUM LTBLU
  ENUM DKRED
  ENUM CYAN
  ENUM MEDRED
  ENUM LTRED
  ENUM DKYEL
  ENUM LTYEL
  ENUM DKGRN
  ENUM MAGENTA
  ENUM GRAY
  ENUM WHT
DROP


DECIMAL
\ GENERATE random motion vectors
: RNDXY  ( -- dx dy ) 120 RND 60 -   120 RND 60 - ;

\ create some motion vectors as double variables (2 cells)
\ use 2@ and 2! on them
CREATE V1    1 ,  0 ,

: .VECTOR  ( -- ) 7 0 AT-XY V1 2@  3 .R 4 .R  ;

: NEWVECTOR
          RNDXY 2DUP 1 MOTION  V1 2!  \ change motion & record vector
         .VECTOR ;

\ Usage:  V1 REVERSE
: REVERSE ( motion-vector-addr -- )
          DUP 2@ NEGATE SWAP NEGATE SWAP ROT 2!
          V1 2@  1 MOTION ;

: SP.POS+ ( dx dy spr# -- )  \ add dx dy sprite's position
          DUP >R  SP.Y VC@ + R@ SP.Y VC!
              R@ SP.X VC@ + R> SP.X VC! ;

: MAKE-FACE
      TOPLEFT   [CHAR] t CHARDEF
      BOTLEFT   [CHAR] u CHARDEF
      TOPRIGHT  [CHAR] v CHARDEF
      BOTRIGHT  [CHAR] w CHARDEF ;

: MAKE-SPRITES ( -- )
      \ Ptrn    clr     col  row  spr#
      \ ------  ---     ---  ---  ----
      [CHAR] w  DKYEL    20   80   1   SPRITE
      [CHAR] w  DKRED    10   16   2   SPRITE
      [CHAR] w  LTGRN   125   16   3   SPRITE
      [CHAR] w  MAGENTA 220  16    4   SPRITE
      [CHAR] w  LTRED    10  170   8   SPRITE
      [CHAR] w  DKBLU   125  170   9   SPRITE
      [CHAR] w  LTBLU   220  170  10   SPRITE  ;

: TINK     GEN1 2100 HZ -6 DB ;

: BOUNCE ( -- )  \ bounce off each other
           V1 REVERSE
           DKRED 1 SP.COLOR
           TINK
           150 MS \ move back to 1/4 second
           MUTE
           0 0 1 MOTION            \ stop moving
           11 2
           DO
              I 1 SP.COLOR         \ show your frustration
              10 MS
           LOOP
           DKYEL 1 SP.COLOR ;      \ normal happy face color

: ?BREAK   ?TERMINAL  IF  STOPMOTION  HONK ." *BREAK*"  ABORT THEN ;

\ Sprite #1 moves and changes color if it collides
: RUN
       PAGE
       DKGRN SCREEN
       2 MAGNIFY
       MAKE-FACE
       INITMOTION
       MAKE-SPRITES
       SPR# 1+ MOVING    \ flag all sprites as movers
       AUTOMOTION
       ." MOTION:" 10 SPACES ." X/Y:"
       BEGIN
         NEWVECTOR
         21 0 AT-XY 1 POSITION 3 .R 4 .R
         1000 RND 100 + 0              \ stay with one vector for a time
         DO
           1 2 5 COINC
           IF   BOUNCE
           THEN ?BREAK
         LOOP
       AGAIN ;
