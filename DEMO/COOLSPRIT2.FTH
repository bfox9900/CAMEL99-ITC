\ Forth Progamming style demo BJFox 2019
\ Concept:  Compare this program to DSK3.COOLSPRITE
\           COOLSPRITE is a literal translation of BASIC to Forth
\ Here we re-worked the program to show Forth language style:
\ 1. Factoring into small words for faster testing each piece
\ 2. Removing CPU variables, passing data on the stack instead.
\ 3. Custom sound effects created without sound list, just Forth code
\    These are not really possible in BASIC because the loops are too slow.

NEEDS MOTION FROM DSK1.AUTOMOTION
NEEDS RND    FROM DSK1.RANDOM
NEEDS DB     FROM DSK1.SOUND

HEX
CREATE ABULLET 0000 , 0018 , 1800 , 0000 ,

\ return random coordinate. NO variables needed thank you
: RNDX  ( -- x ) 192 RND 1+  ;
: RNDY  ( -- y ) 255 RND 1+  ;

: DELSPRITE ( spr# -- ) 0 SWAP PATTERN ;

DECIMAL
\ name sprites and colors for convenience
 1 CONSTANT AMMO    2 CONSTANT TURRET   3 CONSTANT TARGET
 2 CONSTANT BLACK   5 CONSTANT BLUE    16 CONSTANT WHITE

: uS    ( delay -- ) 0 ?DO LOOP ;   \ ~100uS loop speed

: DECAY ( delay start end --) SWAP ?DO   I DB DUP uS   LOOP MUTE DROP ;

\ Why consume CPU RAM with variables?  The numbers are in VDP RAM!
\ We can read the data directly with some CAMEL99 words,
\ compute the motion vectors and put the results on the stack for
\ another routine to use.
: AIMXY ( -- motiony motionx )
        TARGET SP.Y VC@  TURRET SP.Y VC@ - 2/
        TARGET SP.X VC@  TURRET SP.X VC@ - 2/
;

: SHOOT ( -- )
      [CHAR] .  WHITE  TURRET POSITION AMMO SPRITE
       AIMXY AMMO MOTION
       4 NOISE 0 DB  500 uS     \ hi freq shot noise
       5 NOISE 200 2 30 DECAY   \ low freq decay
;

: HIT    ( -- )
         GEN3 1000 HZ -30 DB         \ GEN3 is silent
         3 NOISE 0 DB 700 uS MUTE    \ Noise #3 Freq controlled by GEN3
;

: RUMBLE ( -- )
         6 NOISE 900 10 30 DECAY ;

: CONTACT
         HIT
         AMMO DELSPRITE
        [CHAR] # TARGET PATTERN
         RUMBLE 100 MS MUTE
;

: ?BREAK  ( -- )
          ?TERMINAL
          IF
            STOPMOTION CR CR ." *BREAK*"  HONK ABORT
          THEN
;
\ finally we use our custom made words to make the program
: RUN
       CLEAR  BLUE SCREEN
       5 0 AT-XY ." Camel99 Forth Demo II"
       ABULLET [CHAR] . CHARDEF
       [CHAR] ^   WHITE  1 180 TURRET SPRITE  0 5 TURRET MOTION
       AUTOMOTION
       BEGIN
         25 0
         DO
          [CHAR] A I +  WHITE   RNDY 2/  RNDX 1+  TARGET SPRITE
           SHOOT
           150 MS
           CONTACT
           ?BREAK
         LOOP
       AGAIN ;

CR .( FCTN BREAK to stop demo)
DECIMAL 3000 MS
RUN
