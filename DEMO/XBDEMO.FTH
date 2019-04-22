\ EXTENDED BASIC DEMO ported to CAMEL99 V2

NEEDS CHARSET  FROM DSK1.CHARSET
NEEDS SPRITE   FROM DSK1.DIRSPRIT

CR .( Patterns... )
HEX
0103 070F 1F3F 7FFF PATTERN: CH40   \ LEFT-TRIANGLE
FFFF FFFF FFFF FFFF PATTERN: CH41   \ BLOCK1
80C0 E0F0 F8FC FEFF PATTERN: CH48   \ RIGHT-TRIANGLE
FFFF FFFF FFFF FFFF PATTERN: CH49   \ BLOCK2
FFAA AAAA AAAA AAAA PATTERN: CH56   \ VERT LINES (FENCE)
AAAA AAAA AAAA AAFF PATTERN: CH73   \ FENCE-BOTTOM
0000 0000 0000 0000 PATTERN: CH64   \ empty char
FF80 BFA0 A0A0 A0A0 PATTERN: CH57   \ TOP-LEFT CORNER
FF00 FF00 0000 0000 PATTERN: CH58   \ TOP-DOUBLE-LINE
FF01 FD05 0505 0505 PATTERN: CH59   \ TOP-RIGHT CORNER
0505 0505 0505 0505 PATTERN: CH60   \ VERT-DBL-LINE
0505 0505 05FD 01FF PATTERN: CH61   \ BOT-RIGHT-CORN
0000 0000 00FF 00FF PATTERN: CH62   \ BOT-DOUBLE-LINE
A0A0 A0A0 A0BF 80FF PATTERN: CH63   \ BOT-LEFT-CORN
A0A0 A0A0 A0A0 A0A0 PATTERN: CH72   \ LEFT-DBL-LINE
EEAA AAEE 2222 2222 PATTERN: CH80   \ '99'
8080 0077 5474 4474 PATTERN: CH81   \ 'er
7EFF FFFF FFFF FF7E PATTERN: CH88   \ ROCK
3C3C 3C3C 3C7E 7E99 PATTERN: CH104  \ STUMP
3038 7EFF FFFE 3E3C PATTERN: CH105  \ TOP-CLOUD
0000 0000 183C 3C18 PATTERN: CH106  \ TIRE
0003 0408 7FFF CF87 PATTERN: CH107  \ FRONT-CAR
00F0 8884 FEFF E7C3 PATTERN: CH108  \ BACK-CAR
0000 0000 3C5A 9981 PATTERN: CH109  \ WINGS-DOWN
0081 8142 3C18 1800 PATTERN: CH110  \ WINGS-UP
005C 7E7E FFFF 7600 PATTERN: CLOUD

DECIMAL
: DEF-CHARS
      CH40 40 CHARDEF    CH41 41 CHARDEF
      CH48 48 CHARDEF    CH49 49 CHARDEF
      CH56 56 CHARDEF    CH73 73 CHARDEF
      CH57 57 CHARDEF    CH58 58 CHARDEF
      CH59 59 CHARDEF    CH60 60 CHARDEF
      CH61 61 CHARDEF    CH62 62 CHARDEF
      CH63 63 CHARDEF    CH72 72 CHARDEF
      CH80 80 CHARDEF    CH81 81 CHARDEF
      CH88 88 CHARDEF    CH41 96 CHARDEF

     CH104 104 CHARDEF   CH105 105 CHARDEF
     CH106 106 CHARDEF   CH107 107 CHARDEF
     CH108 108 CHARDEF   CH109 109 CHARDEF
     CH110 110 CHARDEF   CLOUD 111 CHARDEF  ;

.( Sprites... )
: MAKE-SPRITES
\       CHAR CLR COL ROW  SPR#
         104  9  104 130   1 SPRITE  \ treetop
         105 13  104 114   2 SPRITE  \ tree trunk
         106  2  101 116   3 SPRITE  \ BACK TIRE

         108  6  100 109   4 SPRITE  \ BACK CAR
         107  6   84 109   5 SPRITE  \ FRONT CAR

         106  2   82 116   6 SPRITE  \ FRONT TIRE
         111 16   10  31   8 SPRITE  \ cloud1
         111 16   50  13   9 SPRITE  \ cloud2
         111 16  200  50  10 SPRITE  \ cloud3
         109  2  100  35  11 SPRITE  \ bird
;

\ motion support
: SP.X+!  ( n spr# -- ) DUP >R  SP.X@ + R> SP.X! ;
: SP.Y+!  ( n spr# -- ) DUP >R  SP.Y@ + R> SP.Y! ;

: --@    ( variable -- n )  -1 OVER +! @ ;

\ : TIMER: ( n -- )
\          CREATE ( n) , 0 ,
\          DOES>  DUP CELL+ @ 0=
\                 IF   DUP @ OVER CELL+ !  \ load the timer
\                 ELSE CELL+ --@
\                 THEN ;

\ 25 TIMER: CAR-TMR    CAR-TMR ( -- n)

VARIABLE CAR-TMR
: MOVE-CAR ( -- )
       CAR-TMR --@
       0= IF
         -1 3 SP.X+!  \ move 4 sprites together
         -1 4 SP.X+!
         -1 5 SP.X+!
         -1 6 SP.X+!
         20 CAR-TMR !
        THEN  ;

VARIABLE CLOUDTMR
: MOVE-CLOUDS
     CLOUDTMR --@
     0= IF
          -1  8 SP.X+!
          -2  9 SP.X+!
           1 10 SP.X+!
         120 CLOUDTMR !
      THEN ;

VARIABLE BIRDTMR
: MOVE-BIRD
     BIRDTMR --@
     0= IF
          1 11 SP.X+!
          25 BIRDTMR !
      THEN ;

VARIABLE FLAPTMR
: FLAP ( -- )
         FLAPTMR --@
         0= IF  11 SP.PAT VC@    \ read sprite pattern
                109 =
                IF   110 11 PATTERN
                ELSE 109 11 PATTERN
                THEN 75 FLAPTMR !   \ reset timer
         THEN ;

: SET-TIMERS
        10 CAR-TMR !
        37 FLAPTMR !
        60 CLOUDTMR !
        12 BIRDTMR !  ;

DECIMAL
: DEFAULTS          \ restore graphics to BASIC defaults
     4 19 2 8 COLORS
     CHARSET
     8 SCREEN
     DELALL ;
.( Scenery... )
: ROAD  ( -- )
         96 SET# 16 16 COLOR
         0 15  96  64   HCHAR ;

: LOGRASS  ( -- )
         0 17   41   32 7 * HCHAR ;

: HIGRASS  ( -- )
         0 13   49   32 2* HCHAR ;

: FENCE
         56 SET# 2 12 COLOR
         73 SET# 2 12 COLOR
         20 13 56 12 HCHAR
         20 14 73 12 HCHAR ;

: GREEN-COLORS ( -- )
          40 SET# 13 8 COLOR
          48 SET#  4 8 COLOR ;

: .MOUNTAINS ( col row -- )
       AT-XY
       CR   ."                   (0"
       CR   ."    (0            ()10      (0"
       CR   ."   ()10    (0    ())110    ()10"
       CR   ."  ())110  ()10  ()))1110  ())110"
       CR   ." ()))1110())110())))11110()))1110" ;

: ROCK ( -- )
          88 SET#  14 11 COLOR
           7 14 88 1 HCHAR
           9 14 88 1 HCHAR ;

: SIGN-COLORS  ( -- )
          7  9 2 12 COLORS ;

: .SIGN  ( col row -- )
        [CHAR] P SET# 2 12 COLOR
        2DUP    AT-XY ." 9::;"
        1+ 2DUP AT-XY ." HPQ<"
        1+      AT-XY ." ?>>="  ;

.( Main... )
DECIMAL
: RUN   ( -- )
        DELALL
        9 SCREEN
        CLEAR
        DEF-CHARS
        GREEN-COLORS
        32 SET# 8 8 COLOR
        0 7 .MOUNTAINS
        ROAD
        LOGRASS HIGRASS
        SIGN-COLORS
        17 11 .SIGN
        ROCK
        FENCE
        1 MAGNIFY
        MAKE-SPRITES
        SET-TIMERS
        BEGIN
           MOVE-CAR
           MOVE-CLOUDS
           MOVE-BIRD
           FLAP
           ?TERMINAL
        UNTIL
        DEFAULTS ;
