\ SPRITE DEMO using AUTO-motion (SEE: DSK1.MOTION for manual alternative)
CR
CR .( For use with CAMEL99 V2)
CR
CR

NEEDS LOCATE FROM DSK1.DIRSPRIT
NEEDS RND    FROM DSK1.RANDOM
NEEDS MOTION FROM DSK1.AUTOMOTION

\ ========================================
\ demo code
DECIMAL
: MAKE-SPRITES
\ chr  col  Y   X   Sp#
\ -------------------------
   42  16   0  0    0 SPRITE \ *
   65   2   0  5    1 SPRITE \ A
   66   3   0  10   2 SPRITE
   67   4   0  15   3 SPRITE
   68   5   0  20   4 SPRITE
   69  11   0  25   5 SPRITE
   70  11   0  25   6 SPRITE
   71   6   0  30   7 SPRITE
   72   7   0  35   8 SPRITE
   73   5   0  40   9 SPRITE
   74   9   0  45  10 SPRITE
   75  11   0  50  11 SPRITE
   76  12   0  55  12 SPRITE
   77  13   0  60  13 SPRITE
   78  14   0  65  14 SPRITE
   79  15   0  70  15 SPRITE
   80  16   0  75  16 SPRITE
   81   1   0  80  17 SPRITE
   82   2   0  85  18 SPRITE
   83   3   0  90  19 SPRITE
   84   4   0  95  20 SPRITE
   85   5   0 100  21 SPRITE
   86   6   0 105  22 SPRITE
   87   7   0 110  23 SPRITE  \ W
   88   5   0 115  24 SPRITE  \ X
   89   9   0 120  25 SPRITE
   90  10   0 125  26 SPRITE
   48  11   0 130  27 SPRITE  \ 0
   49  12   0 140  28 SPRITE  \ 1
   50  13   0 150  29 SPRITE  \ 2
   51  14   0 160  30 SPRITE  \ 3
   52  16   0 170  31 SPRITE  \ 4
;

: RNDI  ( -- n ) 4 RND 2- ;

: RNDYX ( -- y x ) RNDI  RNDI ;  \ RNDI RNDI ;

\ you can make any sprite move any way with this table
: MY-MOTIONS ( -- )
       \ dX dY   spr#
       \ ----------------------
         10 0     0 MOTION   \ only sprite 0 moves this way.
          5 0     1 MOTION
          5 0     2 MOTION
          5 0     3 MOTION
          5 0     4 MOTION
          5 0     5 MOTION
          5 0     6 MOTION
          5 0     7 MOTION
          5 0     8 MOTION
          5 0     9 MOTION
          5 0    10 MOTION
          5 0    11 MOTION
          5 0    12 MOTION
          5 0    13 MOTION
          5 0    14 MOTION
          5 0    15 MOTION
         -5 0    16 MOTION
         -5 0    17 MOTION
         -5 0    18 MOTION
         -5 0    19 MOTION
         -5 0    20 MOTION
         -5 0    21 MOTION
         -5 0    22 MOTION
         -5 0    23 MOTION
         -5 0    24 MOTION
         -5 0    25 MOTION
         -5 0    26 MOTION
         -5 0    27 MOTION
         -5 0    28 MOTION
         -5 0    29 MOTION
         -5 0    30 MOTION
        -15 0   31 MOTION
;

: RUN
         CLEAR ." 32 sprites moving in Forth"
         CR    ." Using ROM base automotion"
         CR    ." Sprite 0 is 2X faster"
         CR    ." Sprite 31 is 3X faster"
         CR
         CR    ." Type STOPMOTION to stop sprites"
         CR    ." Type AUTOMOTION to move sprites"

         DELALL  MAKE-SPRITES
         250 MS
         0 MAGNIFY
         MY-MOTIONS
         SPR# @ MOVING
         AUTOMOTION
;

CLEAR
CR ." TYPE RUN to start"


