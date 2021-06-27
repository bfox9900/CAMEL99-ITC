\ simple pong DEMO for CAMEL99      Dec 30 2017 B Fox
\ Improved Aug 4 2020

NEEDS RND    FROM DSK1.RANDOM
NEEDS SPRITE FROM DSK1.DIRSPRIT     \ this loads GRAFIX.F first
NEEDS ]HZ    FROM DSK1.SMPLSND      \ 1 voice, decay control
NEEDS CASE   FROM DSK1.CASE
\ ===============================================================
CR .( Compiling PONG)

\ removed from DIRSPRIT library
: SP.Y@   SP.Y VC@ ;
: SP.Y!   SP.Y VC! ;

: SP.X@   SP.X VC@ ;
: SP.X!   SP.X VC! ;

HEX 8375 CONSTANT KVAL

DECIMAL
: CLINK   ( -- ) [ 1650 ]HZ  0 ATT  50 DECAY ;
: CLUNK   ( -- ) [ 1400 ]HZ  2 ATT  50 DECAY ;

VARIABLE HUMAN      \ POINTS variables
VARIABLE COMPUTER

CR .( ..)
HEX
\ screen boundary patterns
0000 00FF FF00 0000 PATTERN: HLINE
1818 1818 1818 1818 PATTERN: VLINE
0000 001F 1F18 1818 PATTERN: ULEFT
0000 00F8 F818 1818 PATTERN: URIGHT
1818 18F8 F800 0000 PATTERN: LRIGHT
1818 181F 1F00 0000 PATTERN: LLEFT

3C7E FFFF FFFF 7E3C PATTERN: BALL
1818 1818 1818 1818 PATTERN: PADDLE
0018 1818 1818 1800 PATTERN: NET

DECIMAL
: ModifyChars ( -- )
         HLINE    0 CHARDEF
         VLINE    1 CHARDEF
         ULEFT    2 CHARDEF
         URIGHT   3 CHARDEF
         LRIGHT   4 CHARDEF
         LLEFT    5 CHARDEF
         BALL   127 CHARDEF
         PADDLE 126 CHARDEF
         NET    128 CHARDEF ;

: Boundary ( -- )
           0  1  2   1 HCHAR
           1  1  0  30 HCHAR
          31  1  3   1 HCHAR
           0  2  1  21 VCHAR
           1 23  0  30 HCHAR
          31  2  1  21 VCHAR
           0 23  5   1 HCHAR
          31 23  4   1 HCHAR ;

: MakeSprites ( -- )
   DELALL
 ( pat colr  x   y  sp# )
   127 16   128 96   0  SPRITE  \ Ball
   126 16     9 96   1  SPRITE  \ human paddle
   126 16   240 96   2  SPRITE  \ computer paddle
;

HEX
: ?KEY   ( -- c|0)  \ repeating key scanner
         0 83C8 !   \ clear previous scan codes
         KEY? ;      \ call KSCAN
\         IF KVAL C@ \ read key value at >8375
\         ELSE 0     \ else return zero
\         THEN ;

: UpDown ( -- -3,0,3 ) \ return a value to move the paddle
         ?KEY CASE
         [CHAR] E OF     -3 ENDOF
         [CHAR] X OF      3 ENDOF
                          0   ( default value)
         ENDCASE ;

: CLIP    ( n min max -- n ) ROT MIN MAX ; \ clip n to within min & max

.( ..)

DECIMAL
 14 CONSTANT TOPWALL
176 CONSTANT BOTWALL

: MovePaddle ( paddle# -- ) \ text macro used for speed
S" DUP >R SP.Y@ UpDown + TOPWALL BOTWALL CLIP  R> SP.Y!" EVALUATE ; IMMEDIATE

VARIABLE XVEC
VARIABLE YVEC

\ compute VDP address from col,row
: >VADDR    ( col row -- vdp_addr)  C/L@ * + ;

 : EraseLine ( col row cnt -- )
             >R >VADDR R> BL VFILL ;

\ clear top line and place cursor at (0,0)
: Prompt  ( -- ) 0 0 2DUP 32 EraseLine   AT-XY ;

: WaitKey  ( char -- ) \ wait until key pressed = char on stack
           BEGIN
             BEGIN
               KEY?
             UNTIL
             KVAL C@ OVER =
           UNTIL
           DROP ;

: MoveBall ( -- ) \ uses direct sprite X,Y read/write
        S" 0 SP.X DUP VC@  XVEC @ + SWAP VC!" EVALUATE ( -- Xaddr x)
        S" 0 SP.Y DUP VC@  YVEC @ + SWAP VC!" EVALUATE ; IMMEDIATE

: BallSpeed ( Yvec Xvec -- )  XVEC !  YVEC ! ;

: PlaceBall ( Y X - ) 0 LOCATE ;

: NEGATE!  ( addr -- )  DUP @ NEGATE SWAP ! ;

: PaddleHit   ( spr# -- )
              CLINK
              XVEC NEGATE!
              0 SP.DIST 20 / 1-   -4 4 CLIP YVEC +!
              MoveBall MoveBall ;

: WallBounce ( -- )   YVEC NEGATE!  MoveBall CLUNK ;

: TopWall  ( sprY -- ) TOPWALL < IF  WallBounce THEN ;
: BotWall  ( sprY -- ) BOTWALL > IF  WallBounce THEN ;
: WallTest ( -- )      0 SP.Y@ DUP  TopWall BotWall ;
: DrawNet  ( -- )      15 2 128 21 VCHAR ;

.( ..)
: FollowBall ( spr# -- ) \ match computer paddle to ball Y coordinate
             0 SP.Y@  SWAP  SP.Y! ;

: ?    ( variable -- ) @ . ;

: ScoreBoard ( -- )
 2 0 AT-XY ." Human      " HUMAN ? ." | "  COMPUTER ? ."     TI-99" ;

: Opening ( -- )
         BEGIN
            MoveBall WallTest
            0 1 7 COINC IF 1 PaddleHit THEN 2 FollowBall
            0 2 7 COINC IF 2 PaddleHit THEN 1 FollowBall
            KEY?
            10 MS
          UNTIL ;

VARIABLE OFFSET
: RandUpDown  ( -- -10 .. 10 ) 50 RND 25 - ;

: ComputerPlayer ( -- )
         0 SP.Y@  RandUpDown +  TOPWALL BOTWALL CLIP 2 SP.Y! ;

: OffBoard? ( ballX -- ?) 253 1  WITHIN ; \ uses reverse logic feature

.( ..)
: PlayGame ( -- )
         BEGIN
            MoveBall WallTest
            0 1 5 COINC IF 1 PaddleHit THEN 1 MovePaddle
            WallTest
            0 2 5 COINC IF 2 PaddleHit THEN ComputerPlayer 1 MovePaddle
            0 SP.X@ OffBoard?
         UNTIL
\ ball went OffBoard...
         XVEC @ 0>        \ positive direction means human played the ball
         IF   1 HUMAN +!
         ELSE 1 COMPUTER +!
         THEN HONK ;

: RandY ( -- n|-n) BEGIN  3 RND 1-  DUP 0 <> UNTIL ;

: RandX ( -- n )   RandY 3 * ;

: DrawCourt ( -- ) Boundary DrawNet ;

: ServeBall ( -- )
         8 21 AT-XY  ." Press ENTER to serve"
         13 WaitKey
         8 21 20 EraseLine
         DrawCourt
         128 96 PlaceBall
         RandY RandX BallSpeed
         1000 RND MS ;    \ wait for it ...

: .WINNER ( -- )
         8 17 AT-XY
         HUMAN @ 5 =
         IF   ." Hey you won!"
         ELSE ." Sorry you lost :-("
         THEN ;

: EndGame? ( -- ? )
         8 19 AT-XY ." Play Again? (Y/N)"
         KEY [CHAR] N =  ( -- ?)
         8 19 22 EraseLine
         8 17 22 EraseLine
         DrawCourt ;
.( ..)
: Winner? ( -- ?)
          HUMAN @ 5 =
          COMPUTER @ 5 =
          OR ;      \ if either play get to 5 they win

: RUN    GRAPHICS
         ModifyChars
         2 SCREEN
         0 17  16 1 COLORS
         DrawCourt MakeSprites
         0 MAGNIFY
         1 -3 BallSpeed
         200 96 PlaceBall
         Prompt ."   PONG! Press any key to begin"
         Opening
         Prompt
         BEGIN  ( play the game )
            HUMAN OFF   COMPUTER OFF
            ScoreBoard
            BEGIN
              ServeBall
              PlayGame
              ScoreBoard
              Winner?
            UNTIL
           .WINNER
            EndGame?
         UNTIL
         GRAPHICS ;

CR  .( Pong compiled)
CR  .( Type RUN to start game)
