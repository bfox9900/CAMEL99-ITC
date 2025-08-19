\ SPRITE test exerise sprite code without multi-tasking
CR
CR .( For use with CAMEL99 V2.0.17 or greater)
CR
CR

NEEDS LOCATE FROM DSK1.DIRSPRIT
NEEDS RND    FROM DSK1.RANDOM
NEEDS MOTION FROM DSK1.MOTION  \ manual motion not Automotion 

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
DECIMAL 
: MY-MOTIONS ( -- )
        \ dx dy   spr#
        \ ----------------------
          10   0   0 MOTION   
30  1 DO   5   0   I MOTION  LOOP 
         -15   0  31 MOTION
;


: SET-MOTIONS   1 0 0 31 MOTIONS ;

: EXPLANATION
         CLEAR ." 32 Sprites Moving in Forth"
         CR
         CR    ." Motion is controlled manually"
         CR    ." Forth is doing the work with"
         CR    ." the DSK1.MOTION library file"
         CR    ." and the word TRANSLATE."
         CR
         CR    ." Sprite  0 is 2X faster"
         CR    ." Sprite 31 is 2X faster"
         CR
         CR    ." Press FNCT 4 to halt demo"
         CR    ." Type: MY-MOTIONS RUN"
         CR    ." to see things moving faster"
;

: RUN    EXPLANATION
         DELALL  MAKE-SPRITES
         0 MAGNIFY
         BEGIN
           0 SPR# @ TRANSLATE    \ move everybody
            0 SP.MOVE            \ move Spr#0 once more
           31 SP.MOVE            \ Move Spr#31 once more
           10 MS 
           ?TERMINAL ABORT" BREAK"
         AGAIN ;

CLEAR
SET-MOTIONS
CR ." Motions are set"
CR ." TYPE RUN to start"
