\ simple pong DEMO for CAMEL99      Dec 30 2017 B Fox
\ Updated for camel99 V2.5 Apr 2020

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS RND    FROM DSK1.RANDOM
NEEDS SPRITE FROM DSK1.DIRSPRIT     \ this loads GRAFIX first
NEEDS HZ     FROM DSK1.SOUND
NEEDS CASE   FROM DSK1.CASE

NEEDS EMPTY  FROM DSK1.EMPTY

EMPTY
\ ===============================================================
CR .( Compiling PONG)

DECIMAL
: DECAY  ( t -- ) 30 0 DO  I DB DUP TICKS  LOOP TICKS MUTE ;
: CLINK   ( -- ) GEN1 1650 HZ  0 DB  25 DECAY ;
: CLUNK   ( -- ) GEN2  400 HZ  2 DB  25 DECAY ;

VARIABLE HUMAN      \ POINTS variables
VARIABLE COMPUTER
CR .( ..)
: PATTERN: CREATE  >R >R >R , R> , R> , R> ,  ;
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
        \  x  y  char n
           0  1   2   1 HCHAR
           1  1   0  30 HCHAR
          31  1   3   1 HCHAR
           0  2   1  21 VCHAR
           1 23   0  30 HCHAR
          31  2   1  21 VCHAR
           0 23   5   1 HCHAR
          31 23   4   1 HCHAR ;

\ SPRITES can have names in Forth
0 CONSTANT #BALL
1 CONSTANT #HUMAN
2 CONSTANT #TI99

16 CONSTANT WHITE
: MakeSprites ( -- )
   DELALL
 ( pat  colr    x   y    sp# )
   127  WHITE  128 96   #BALL  SPRITE  \ Ball
   126  WHITE    9 96   #HUMAN SPRITE  \ human paddle
   126  WHITE  240 96   #TI99 SPRITE  \ computer paddle
;

HEX
: ?KEY   ( -- c|0)  \ repeating key scanner
         83C8 OFF   \ clear previous scan codes
         KEY?  ;

: UpDown ( -- -3,0,3 ) \ return a value to move the paddle
         ?KEY
         CASE
         [CHAR] E OF     -2 ENDOF
         [CHAR] X OF      2 ENDOF
                          0   ( default value)
         ENDCASE ;

: CLIP    ( n min max -- n ) ROT MIN MAX ; \ clip n to within min & max

.( ..)

DECIMAL
 13 CONSTANT TOPWALL
177 CONSTANT BOTWALL

: MovePaddle ( paddle# -- )
          DUP >R SP.Y VC@ UpDown +
          TOPWALL BOTWALL CLIP  R> SP.Y VC!
;

VARIABLE XVEC
VARIABLE YVEC

 : EraseLine ( col row cnt -- ) >R >VPOS R> BL VFILL ;

\ clear top line and place cursor at (0,0)
: Prompt  ( -- ) 0 0 2DUP C/L@ EraseLine   AT-XY ;

: WaitKey  ( char -- ) \ wait until key pressed = char on stack
           BEGIN
             ?TERMINAL IF  TEXT ." Forth" ABORT  THEN
             KEY? OVER =
           UNTIL
           DROP ;

: MoveBall ( -- ) \ uses direct sprite X,Y read/write
           #BALL SP.X DUP VC@ ( -- Xaddr x) XVEC @ + SWAP VC!
           #BALL SP.Y DUP VC@ ( -- Yaddr y) YVEC @ + SWAP VC! ;

: BallSpeed ( Yvec Xvec -- )  XVEC !  YVEC ! ;

: PlaceBall ( Y X - ) 0 LOCATE ;

: NEGATE!  ( addr -- )  DUP @ NEGATE SWAP ! ;

\ compare y coodidnate of ball and paddle.
\ Compute adjustment for Y vector to bounce off. Limited to +/- 5
: PADDLE.HIT-POINT ( #sprite -- n )
     SP.Y VC@  #BALL SP.Y VC@ SWAP - 2/ -4 4 CLIP
    4 20 AT-XY DUP .  ( debugging )
;

: PaddleHit   ( spr# -- )
      XVEC NEGATE!
      PADDLE.HIT-POINT  YVEC +!
      CLINK
      MoveBall  MoveBall \ get clear of paddle
;

: WallBounce ( -- ) YVEC NEGATE! CLUNK  MoveBall MoveBall ;

: TopWall  ( sprY -- ) TOPWALL < IF  WallBounce THEN ;
: BotWall  ( sprY -- ) BOTWALL > IF  WallBounce THEN ;
: WallTest ( -- )      0 SP.Y VC@ DUP  TopWall BotWall ;
: DrawNet  ( -- )      15 2 128 21 VCHAR ;

.( ..)

: FollowBall ( spr# -- ) \ match computer paddle to ball Y coordinate
           #BALL SP.Y VC@  SWAP  SP.Y VC! ;

: ?    ( variable -- ) @ . ;

: ScoreBoard ( -- )
       2 0 AT-XY ." Human      " HUMAN ?
       ." | "  COMPUTER ? ."     TI-99" ;

: Opening ( -- )
         BEGIN
            200 TICKS
            MoveBall WallTest
            #BALL #HUMAN 4 COINC IF #HUMAN PaddleHit THEN #TI99 FollowBall
            #BALL #TI99  4 COINC IF #TI99 PaddleHit THEN #HUMAN FollowBall
            KEY?
          UNTIL ;

VARIABLE OFFSET
: RandUpDown  ( -- -10 .. 10 )   20 RND 10 - ;

: ComputerPlayer ( -- )
        #BALL SP.Y VC@  RandUpDown +  TOPWALL BOTWALL CLIP #TI99 SP.Y VC! ;

: OffBoard? ( ballX -- ?) 1  253 WITHIN 0= ;

.( ..)
: PlayGame ( -- )
         BEGIN
            MoveBall
            WallTest
            #BALL 1 8 COINC IF 1 PaddleHit THEN #HUMAN MovePaddle
            #BALL 2 6 COINC IF 2 PaddleHit THEN ComputerPlayer #HUMAN MovePaddle
            #BALL SP.X VC@ OffBoard?
         UNTIL
\ ball went OffBoard...
         XVEC @ 0>        \ positive direction means human played the ball
         IF   1 HUMAN +!
         ELSE 1 COMPUTER +!
         THEN HONK ;

: RandY ( -- n|-n) BEGIN  3 RND 1-  DUP 0 <> UNTIL ;

: RandX ( -- n )   RandY 3 * ;

: DrawCourt ( -- ) Boundary DrawNet ;

13 CONSTANT <ENTER>

: ServeBall ( -- )
         8 21 AT-XY  ." Press ENTER to serve"
         <ENTER> WaitKey
         8 21 20 EraseLine
         DrawCourt
         128 96 PlaceBall
         RandY RandX BallSpeed
         2000 RND 200 + MS ;    \ wait for it ...

: .WINNER ( -- )
         8 17 AT-XY
         HUMAN @ 5 =
         IF   ." Hey you won!"
         ELSE ." Sorry you lost :-("
         THEN ;

: 'N'=  ( c -- ?) DUP [CHAR] N =  SWAP [CHAR] n = OR ;

: EndGame? ( -- ? )
        8 19 AT-XY ." Play Again? (Y/N)"
        KEY  'N'=
        8 19 22 EraseLine
        8 17 22 EraseLine
        DrawCourt
;

.( ..)
: Winner? ( -- ?)
          HUMAN @ 5 =
          COMPUTER @ 5 =
          OR ;      \ if either play get to 5 they win

: SETUP
      GRAPHICS
      ModifyChars
      2 SCREEN
      0 17  16 1 COLORS
      DrawCourt MakeSprites
      0 MAGNIFY
      1 -3 BallSpeed
      200 96 PlaceBall
;

: RUN
         SETUP
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
         BYE  ;

CR  .( Pong compiled)
CR  .( Type RUN to start game)
