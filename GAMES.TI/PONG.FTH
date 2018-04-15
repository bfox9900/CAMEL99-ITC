\ simple pong DEMO for CAMEL99      Dec 30 2017 B Fox

INCLUDE DSK1.RANDOM.F
INCLUDE DSK1.GRAFIX.F

\ ======================================================
CR  .( direct SPRITE control lexicon )
HEX
8802   CONSTANT VDPSTS         \ vdp status register memory mapped address

300    CONSTANT SDT            \ sprite descriptor table address in VDP RAM
20 4*  CONSTANT SDTsize        \ size of the table, 32 sprites x 4 bytes/record
1F     CONSTANT MAX.SP         \ 32 sprites, 0 .. 31
8364   CONSTANT SPR#           \ sprite counter is kept in FAST RAM

\ Sprite descriptor table array
: ]SDT     ( char# -- sdt[n])  4* SDT + ;  

\ named fields for sprite record.  Usage:  12 ]SDT ->PAT
: ->PAT   ( addr -- addr+2) POSTPONE 2+  ; IMMEDIATE
: ->COLR  ( addr -- addr+3) POSTPONE 3 POSTPONE + ; IMMEDIATE

\ finger trouble protection. Runtime array index test.
: ?NDX  ( n -- n ) MAX.SP  OVER U< ABORT" SPR#>31"  ;

\ INIT SPRITES: You must run DELALL before using sprites*
: DELALL  ( -- )
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT SDTsize BL VFILL  \ init the sprite desc. table with blanks
          SPR# OFF ;            \ #sprites=0

\ The following words are named like Extended BASIC
\ (remove ?NDX if you need more speed, but you have no protection)
\ read 2 bytes, split them
: POSITION  ( sprt# -- dx dy ) ?NDX  ]SDT V@ SPLIT  ;

\ store 2 fused bytes
: LOCATE    ( dx dy sprt# -- ) ?NDX  >R FUSE R> ]SDT V! ;
: PATTERN   ( char sprt# -- )  ?NDX  ]SDT ->PAT VC! ;

 \ uses TI BASIC color #s
: SP.COLOR  ( col sprt# -- )   ?NDX  >R 1- R> ]SDT ->COLR VC! ;

: SPRITE  ( char colr x y sp# -- )     \ create a SPRITE, sp# = 0..31
             DUP >R          \ copy spr# to rstack
                LOCATE       \ set screen position
             R@ SP.COLOR     \ set the sprite color
             R@ PATTERN      \ set the character pattern to use
             R> SPR# @ >     \ is this sprite# > last sprite made
             IF 1 SPR# +!    \ if so, increment the sprite counter
             THEN ;

\ faster access to Sprite descriptor table X,Y bytes 
\ than using LOCATE and Position
\ ** NO sprite# limits, be careful **

: SP.X   ( spr# -- vdp_addr) ]SDT 1+ ;
: SP.Y   ( spr# -- vdp_addr) ]SDT ;
: SP.X@  ( spr# -- sprx) ]SDT 1+ VC@ ;    \ fetch X
: SP.Y@  ( spr# -- spry) ]SDT VC@ ;    \ fetch Y

: SP.X!  ( n spr# -- ) ]SDT 1+ VC! ;      \ store X
: SP.Y!  ( n spr# -- ) ]SDT VC! ;      \ store Y

\ like Extended BASIC Magnify
: MAGNIFY  ( mag-factor -- ) 83D4 C@ 0FC AND + DUP 83D4 C!  1 VWTR ;

HEX
: 2(X^2)   ( n -- 2(n^2) S" DUP * 2* " EVALUATE ;  IMMEDIATE

( factored DIST out from SPRDISTXY in TI-Forth)
: DIST     ( x2 y2 x1 y1 -- distance^2) \ distance between 2 coordinates
            DXY 2DUP +       \ sum the squares (DXY is code word)
            DUP >R           \ push a copy
            OR OR 8000 AND   \ check out of range
            IF R> DROP 7FFF  \ throw away the copy, return 32K
            ELSE R>          \ otherwise return the calculation
            THEN ;

: SP.DIST   ( #1 #2 -- dist^2 )         \ distance between 2 sprites
            POSITION ROT POSITION DIST ;

: SP.DISTXY ( x y # -- dist^2 ) POSITION DIST ;

: <=        ( n n -- ? ) POSTPONE 1- POSTPONE < ; IMMEDIATE

: COINC     ( sp#1 sp#2 tol -- ? ) \ ? = 0 = no coinc
            2(X^2) >R SP.DIST  R> <= ;

: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R   \ convert tolerance  to squares, push to rstack
            SP.DISTXY   \ compute sprite dist from dx dy
            R> <= ;     \ compare dist to tolerance

\ bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ; 

\ ===============================================================
CR  .( simplied sound control)
DECIMAL
: f(clk) ( -- d) 46324 1  ;   \ this is 111,860 as 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
: >FCODE   ( 0abc -- 0cab)    \ ASM would make this much faster
           DUP 0F AND SWAP      ( -- 000c 0abc)
           4 RSHIFT             ( -- 000c 00ab)
           SWAP ><  ( SWPB)     ( -- 00ab 0c00)
           + ;

: HZ>CODE  ( freq -- fcode )  f(clk) ROT UM/MOD NIP >FCODE 8000 OR  ;

\ [HZ] is macro that calcs 9919 chip frequency code at compile time
\  and then compiles it as a literal 16 bit number.
: [HZ] ( freq -- fcode ) S" HZ>CODE ] LITERAL" EVALUATE ;

\ sound channel #1 control words
: FREQ!    ( fcode -- ) SPLIT SND! SND! ;
: ]HZ      ( freq -- ) [HZ]  COMPILE FREQ! ;  \ pre-calculates fcode
: DB       ( n -- )    90 OR SND! ;
: MUTE     ( -- )      9F SND! ;

HEX
: WAIT     ( n -- )      0 ?DO LOOP ;   \ 100us delay
: DECAY    ( speed -- )  10  0  DO  I DB  DUP WAIT  LOOP DROP  ;


\ ===============================================================
\                 ***  PONG  BEGINS HERE ***
\         ==============================================
DECIMAL
: CLINK   ( -- ) [ 1650 ]HZ  0 DB  50 DECAY ;
: CLUNK   ( -- ) [ 1400 ]HZ  2 DB  50 DECAY ;

VARIABLE HUMAN              \ POINTS variables
VARIABLE COMPUTER
CR  .( ..)
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
         KEY?       \ call KSCAN
         IF KVAL C@ \ read key value at >8375
         ELSE 0     \ else return zero
         THEN ;

: UpDown ( -- -3,0,3 ) \ return a value to move the paddle
         ?KEY
         [CHAR] E OVER = IF  -4 ELSE
         [CHAR] X OVER = IF   4 ELSE
                              0   ( default value)
         THEN THEN NIP ;

: CLIP    ( n min max -- n ) ROT MIN MAX ; \ clip n to within min & max
  .( ..)

DECIMAL
 13 CONSTANT TOPWALL
177 CONSTANT BOTWALL

: MovePaddle ( paddle# -- )
           DUP >R SP.Y@ UpDown +
           TOPWALL BOTWALL CLIP  R> SP.Y! ;

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
           0 SP.X DUP VC@ ( -- Xaddr x) XVEC @ + SWAP VC!
           0 SP.Y DUP VC@ ( -- Yaddr y) YVEC @ + SWAP VC! ;

: BallSpeed ( Yvec Xvec -- )  XVEC !  YVEC ! ;

: PlaceBall ( Y X - ) 0 LOCATE ;

: NEGATE!  ( addr -- )  DUP @ NEGATE SWAP ! ;

: PaddleHit   ( spr# -- )
              XVEC NEGATE!
              0 SP.DIST 20 / 1-   -4 4 CLIP YVEC +!
              MoveBall CLINK ;

: WallBounce ( -- )   YVEC NEGATE!  MoveBall CLUNK ;

: TopWall  ( sprY -- ) TOPWALL < IF  WallBounce THEN ;
: BotWall  ( sprY -- ) BOTWALL > IF  WallBounce THEN ;
: WallTest ( -- )      0 SP.Y@ DUP  TopWall BotWall ;
: DrawNet  ( -- )      15 2 128 21 VCHAR ;

: FollowBall ( spr# -- ) \ match computer paddle to ball Y coordinate
             0 SP.Y@  SWAP  SP.Y! ;
             
: ?    ( variable -- ) @ . ;

: ScoreBoard ( -- )
       2 0 AT-XY ." Human      " HUMAN ?  
       ." | "  COMPUTER ? ."     TI-99" ;

: Opening ( -- )
         BEGIN
            MoveBall WallTest
            0 1 4 COINC IF 1 PaddleHit THEN 2 FollowBall
            0 2 4 COINC IF 2 PaddleHit THEN 1 FollowBall
            KEY?
          UNTIL ;

VARIABLE OFFSET
: RandUpDown  ( -- -10 .. 10 )   50 RND 25 - ;

: ComputerPlayer ( -- )
         0 SP.Y@  RandUpDown +  TOPWALL BOTWALL CLIP 2 SP.Y! ;

: OffBoard? ( ballX -- ?) 1  253 WITHIN 0= ;

: PlayGame ( -- )
         BEGIN
            MoveBall 
            WallTest
            0 1 5 COINC IF 1 PaddleHit THEN 1 MovePaddle
            0 2 5 COINC IF 2 PaddleHit THEN ComputerPlayer
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

: Winner? ( -- ?)
          HUMAN @ 5 =
          COMPUTER @ 5 = 
          OR ;      \ if either play get to 5 they win

: RUN    GRAPHICS
         ModifyChars
         2 SCREEN
         0 17  16 1 COLORS
         DrawCourt MakeSprites
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



