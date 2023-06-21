\ BREAKOUT.FTH  on Camel99 Forth     Aug 2022 Brian Fox
\ Updated June 21 2023

\ Uses DSK1.MOTION library. 
\ MOTION sets SPRITE motion vector. SP.MOVE moves sprite 1 increment.
\ See the file dsk1.motion for more details

\ NEEDS DUMP   FROM DSK1.TOOLS ( debugging)

NEEDS HCHAR  FROM DSK1.GRAFIX
NEEDS SPRITE FROM DSK1.DIRSPRIT
NEEDS MOTION FROM DSK1.MOTION
NEEDS DATA   FROM DSK1.DATABYTE
NEEDS RND    FROM DSK1.RANDOM
NEEDS HZ     FROM DSK1.SOUND
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS MARKER FROM DSK1.MARKER
NEEDS CASE   FROM DSK1.CASE
NEEDS JOYST  FROM DSK1.JOYST 
NEEDS QUIT-ON FROM DSK1.QUITKEY 
NEEDS YIELD  FROM DSK1.MTASK99 
NEEDS VALUE  FROM DSK1.VALUES 
NEEDS U.R    FROM DSK1.UDOTR 

: EMPTY S" REMOVE MARKER REMOVE" EVALUATE ;

MARKER REMOVE

EMPTY

\ allocate task space in heap, fork it, assign Execution, return PID
: SPAWN  ( xt -- pid)  USIZE MALLOC DUP >R FORK  R@ ASSIGN  R> ;
 
\ Extensions to MOTION 
\ Access the VECTOR table in dsk1.motion, via x and y separately
: VECT.Y ( n -- addr) POSTPONE ]VECTOR ; IMMEDIATE 
: VECT.X ( n -- addr) POSTPONE ]VECTOR POSTPONE CELL+ ; IMMEDIATE 

\ ***************************
\ the variables
\ ***************************
VARIABLE BALL#
VARIABLE SCORE
VARIABLE 'BALL      \ record the position so we don't calculate it twice
VARIABLE REMAINING  \ # squares left to win
VARIABLE SPEED 
\ 0 VALUE PADDLE-CTRL 

\ ***************************
\ handy primitives
\ ***************************

: CLIP    ( n lo hi -- n')  ROT MIN MAX ;
: FGCOLOR ( set# fg -- ) 1 COLOR ;
: BALLS   ( n -- )  BALL# ! ;

\ ***************************
\ named colors
\ ***************************
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
  ENUM WHITE
DROP

\ ***************************
\ named SPRITES
\ ***************************
1 CONSTANT BALL
0 CONSTANT PADDLE  

\ ***************************
\ sounds for the game
\ ***************************
DECIMAL
: CLINK ( freq -- )
    GEN1 HZ
     0 DB 600 TICKS
     6 DB 400 TICKS
    10 DB 400 TICKS
    MUTE ;

: BONK  ( -- )
    GEN1 110 HZ 
     0 DB 1000 TICKS
     6 DB 2000 TICKS
    12 DB 2000 TICKS
    MUTE ;

\ ***************************
\ random numbers
\ ***************************
: RNDV     ( -- -1|0|1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;
: SERVING  ( -- dx dy)  NON-0 1  ;

\ ***************************
\ number patterns
\ ***************************
HEX
CREATE NUMERALS
  DATA 0000,7E66,6666,7E00     \ 48
  DATA 0000,1818,1818,1800     \ 49
  DATA 0000,7E06,7E60,7E00     \ 50
  DATA 0000,7E06,3E06,7E00     \ 51
  DATA 0000,6666,7E06,0600     \ 52
  DATA 0000,7C60,7C0C,7C00     \ 53
  DATA 0000,6060,7E62,7E00     \ 54
  DATA 0000,7E06,0606,0600     \ 55
  DATA 0000,7E66,7E66,7E00     \ 56
  DATA 0000,7E66,7E06,7E00     \ 57

DECIMAL
: DEF-NUMBERS ( --)  NUMERALS 48 ]PDT 10 8* VWRITE ;

\ ****************************************
\ * Character Patterns
\ ****************************************
HEX
CREATE SQUARE DATA FFFF,FFFF,FFFF,FFFF


\ ****************************************
\ * Sprite Patterns                       
\ ****************************************
CREATE PADDLE-PATTERN    
    DATA 0000,0000,00FF,00FF  
    DATA 00FF,00FF,0000,0000   
    DATA 0000,0000,00FF,00FF   
    DATA 00FF,00FF,0000,0000   

CREATE BALL-PATTERN
    DATA 0000,0000,0307,0F0F 
    DATA 0F07,0300,0000,0000
    DATA 0000,0000,80C0,E0E0 
    DATA E0C0,8000,0000,0000


\ ***************************
\ Name the characters & put in different character sets
\ ***************************
DECIMAL
      128   CONSTANT BORDER  \ start past ASCII chars
BORDER  8 + CONSTANT MAGBAR
MAGBAR  8 + CONSTANT REDBAR
REDBAR  8 + CONSTANT YELBAR
YELBAR  8 + CONSTANT GRNBAR
GRNBAR  8 + CONSTANT BLUBAR
BLUBAR  8 + CONSTANT VIOBAR
VIOBAR  8 + CONSTANT BLKSQR
BLKSQR  8 + CONSTANT BALLCHARS
BALLCHARS 8 + CONSTANT PADDLECHARS

: SPRITE-DEF ( addr char -- ) ]PDT 64 VWRITE ;

: DEF-SHAPES
    SQUARE BORDER CHARDEF
    SQUARE MAGBAR CHARDEF
    SQUARE REDBAR CHARDEF
    SQUARE YELBAR CHARDEF
    SQUARE GRNBAR CHARDEF
    SQUARE BLUBAR CHARDEF
    SQUARE VIOBAR CHARDEF
    SQUARE BLKSQR CHARDEF
    BALL-PATTERN   BALLCHARS   SPRITE-DEF
    PADDLE-PATTERN PADDLECHARS SPRITE-DEF
;

: SETCOLORS
     BORDER SET#  GRAY    FGCOLOR
     MAGBAR SET#  MAGENTA FGCOLOR
     REDBAR SET#  DKRED   FGCOLOR
     YELBAR SET#  DKYEL   FGCOLOR
     GRNBAR SET#  DKGRN   FGCOLOR
     BLUBAR SET#  DKBLU   FGCOLOR
     VIOBAR SET#  LTBLU   FGCOLOR
     BALLCHARS SET# WHITE   FGCOLOR
     PADDLECHARS SET# MAGENTA FGCOLOR
     [CHAR] 0 SET# WHITE FGCOLOR
     [CHAR] 9 SET# WHITE FGCOLOR
     [CHAR] A SET#  12  GRAY 1 COLORS 
;

: DRAW.BORDER
       0 2 BORDER 32 HCHAR
       0 3 BORDER 32 HCHAR
       0 3 BORDER 21 VCHAR
       1 3 BORDER 21 VCHAR
      30 3 BORDER 21 VCHAR
      31 3 BORDER 21 VCHAR
;

: RAINBOW
       2  7 MAGBAR 28 HCHAR
       2  8 REDBAR 28 HCHAR
       2  9 YELBAR 28 HCHAR
       2 10 GRNBAR 28 HCHAR
       2 11 BLUBAR 28 HCHAR
       2 12 VIOBAR 28 HCHAR
;

: BALL.HOME          ( X   Y ) 
    BALLCHARS  WHITE  127 104  BALL SPRITE 
    SERVING BALL MOTION ;

: .SCORE  ( -- ) 4 0 AT-XY SCORE @ 5 U.R ;
: .BALLS  ( -- ) 20 0 AT-XY BALL# @ 2 .R  ;

: .PADDLE ( -- ) PADDLECHARS MAGENTA 127 176 PADDLE SPRITE ;

: START-POSITIONS    BALL.HOME  .SCORE  .BALLS   .PADDLE ;

: DRAW.SCR    
  SETCOLORS  BLACK SCREEN  DRAW.BORDER
  .SCORE  .BALLS  RAINBOW  ;

\ ***************************
\ coordinate conversion
\ ***************************
\ : PIX>CHAR ( pixel -- n) 1- 3 RSHIFT 1+ ;
\ : CHAR>PIX ( n -- pixel) 8*  7 - ;
HEX                   ( TOS DEC,  TOS 3 SRA,  TOS INC, )
CODE PIX>CHAR ( pixel -- n) 0604 , 0834 , 0584 , NEXT, ENDCODE 

DECIMAL
: BALLADDR ( -- vaddr)
  BALL SP.Y V@ SPLIT 
  PIX>CHAR SWAP PIX>CHAR SWAP >VPOS
  DUP 'BALL ! ;

: UNDERBALL ( pix piy -- c) BALLADDR VC@ ;
: BOUNCE.X  ( spr# --) VECT.X  DUP @ NEGATE SWAP ! ( BALL SP.MOVE) ;
: BOUNCE.Y  ( spr# --) VECT.Y  DUP @ NEGATE SWAP ! ( BALL SP.MOVE) ;
: FALLING?  BALL VECT.Y @ 0> ;
: RISING?   BALL VECT.Y @ 0< ;

: OFFSET ( -- n)  
  PADDLE SP.X VC@  
  BALL SP.X VC@ - 2 /  -1 1 CLIP ;    

 DECIMAL 
\ clipped for sprite column boundaries
: VC+!  ( n Vaddr --) DUP>R  VC@ +  17 223 CLIP  R> VC! ;
: PADDLE+!   PADDLE SP.X VC+!  ;


\ ***************************************
\ ball movement and collision detection
\ ***************************************

: PADDLE?  ( -- ?) BALL PADDLE 8 COINC ;

: BALL.MOVE    SPEED @ TICKS  BALL SP.MOVE ;

: MOVES  0 ?DO  BALL.MOVE LOOP ;

: WALL?    ( --?) UNDERBALL BORDER = ; 
: CLEAR-WALL  BEGIN  WALL?    WHILE  BALL.MOVE  REPEAT ;

: TOPWALL? ( --?) BALL SP.Y VC@ 32 < ;
: CLEAR-TOP   BEGIN  TOPWALL? WHILE  BALL.MOVE  REPEAT ;

: TOPBOUNCE   TOPWALL? IF  BALL BOUNCE.Y  CLEAR-TOP  THEN ;
: SIDEBOUNCE  WALL?    IF  BALL BOUNCE.X  CLEAR-WALL  THEN ;
: WALL-BOUNCE ( -- ) TOPBOUNCE SIDEBOUNCE ;

: PADDLE-BOUNCE 
  BALL BOUNCE.Y 
  BEGIN PADDLE? 
  WHILE 
    BALL.MOVE
  REPEAT ;    

: PADDLE-HIT ( -- ) 
    600 CLINK   
    PADDLE-BOUNCE 
    SIDEBOUNCE 
;

DECIMAL 
: JOYKEY  ( -- n) \ wait for any joystick output 
  BEGIN  
    PAUSE 
    0 JOYST 
    ?DUP 
  UNTIL ;

: WAIT-FIRE    BEGIN  JOYKEY 1 = UNTIL ;
  
: .REPLAY 
  DELALL 
  11 21 AT-XY ." GAME OVER"
   5 22 AT-XY ." PRESS FIRE TO PLAY AGAIN"
  WAIT-FIRE 
  400 MS 
;

: ERASELN  ( -- ) >VPOS 28 BL VFILL ;

: SCORE-MULTIPLIER
    SCORE @ 1
    ?DO  
      4 0 AT-XY I 5 U.R
      9 9 AT-XY ." MULTIPLIER!"
      750 CLINK 
      2 9 ERASELN
    9 +LOOP 
    SCORE @ BALL# @ *  SCORE !
    .SCORE
   
;

: .BALL# 
   BALL# @ DUP . ." BALL" IF ." S" THEN  ;

: ?WIN 
   REMAINING @ IF  EXIT  THEN   
   DELALL 
   10 5 AT-XY ." HEY YOU WON !!" 
    4 7 AT-XY ." WITH " .BALL#  ."  REMAINING"
    BALL# @ 1 > IF  SCORE-MULTIPLIER  THEN 
    28 6 * REMAINING !  \ # blocks to WIN
    BALL# OFF 
    .REPLAY 
  ;

\ for debugging
\ : ?BREAK     
\  ?TERMINAL 
\  IF CYAN SCREEN TRUE ABORT" BREAK" 
\  THEN ;


: RICOCHET ( points freq --)
  CLINK
  BL 'BALL @ VC! 
  PAUSE 
  BALL BOUNCE.Y  SCORE +!  .SCORE 
  PAUSE 
  REMAINING 1-! ;

: BALLINPLAY
    BEGIN
      ?WIN 
      BALL.MOVE
      PADDLE? IF  PADDLE-HIT THEN 
      UNDERBALL ( char)
      CASE      \ points  Freq.
        MAGBAR   OF 6     1500 RICOCHET    ENDOF
        REDBAR   OF 5     1400 RICOCHET    ENDOF
        YELBAR   OF 4     1300 RICOCHET    ENDOF
        GRNBAR   OF 3     1200 RICOCHET    ENDOF
        BLUBAR   OF 2     1100 RICOCHET    ENDOF
        VIOBAR   OF 1     1000 RICOCHET    ENDOF
        BORDER   OF WALL-BOUNCE 200 CLINK  ENDOF
      ENDCASE
      PAUSE 
      BALL SP.Y VC@ 200 >
    UNTIL         
    BONK               \ missed the ball return   
    BALL# 1-! .BALLS  
;

: CLS      ( -- ) 24 13 DO  2 I ERASELN  LOOP ; 

: SETUP ( -- ) 
  DEF-NUMBERS  DEF-SHAPES  
  SETCOLORS  SCORE OFF 
  2 MAGNIFY 
  10 BALLS 
  28 6 * REMAINING !  \ # blocks to WIN
  CLEAR ;

: .PRESS-FIRE
    6 22 AT-XY ." PRESS FIRE TO SERVE" 
    WAIT-FIRE
    2 22 ERASELN ;

: .CREDITS 
   5 14 AT-XY ." RAINBOW BUSTER VER 3.1"
   9 15 AT-XY ."   FOR TI-99"
   6 16 AT-XY ." BY BRIAN FOX 2023" 

   4 23 AT-XY ." PRESS A KEY TO CONTINUE"
   KEY DROP   
;    

: SET-SPEED 
     KEY 
     CASE 
      [CHAR] 1 OF  300 SPEED !  ENDOF 
      [CHAR] 2 OF  150 SPEED !  ENDOF 
      [CHAR] 3 OF   50 SPEED !  ENDOF 
                   150 SPEED ! ( default to medium)
     ENDCASE 
;

: LEVEL-MENU 
  CLS 
  11 14 AT-XY ." SKILL LEVEL"
   9 16 AT-XY ." 1 BEGINNER"
   9 17 AT-XY ." 2 GAMER"
   9 18 AT-XY ." 3 OLYMPIC"
  11 19 AT-XY  SET-SPEED
  CLS
;

\ ********************************************
\ Joystick control runs as a background task
\ ********************************************
        
: PADDLE-MOVER 
    BEGIN 
      JOYKEY 
      CASE
        2 OF  -2 PADDLE+!  ENDOF
        4 OF   2 PADDLE+!  ENDOF 
      ENDCASE
      SPEED @ 2* TICKS 
    AGAIN    \ never stops because it is a separate task 
; 

' PADDLE-MOVER CONSTANT PADDLE-TASK

: GO
    DECIMAL
    QUIT-ON
    PADDLE-TASK SPAWN WAKE 
    MULTI       
    BEGIN 
      SETUP  
      DRAW.SCR
      .CREDITS 
      LEVEL-MENU
      .PRESS-FIRE
      CLS
      BEGIN
        BALL# @
      WHILE
        SERVING BALL MOTION 
        START-POSITIONS
        WAIT-FIRE 
        BALLINPLAY 
      REPEAT
      .REPLAY
    AGAIN 
;

: STARTER   WARM  GRAPHICS INIT-MULTI  GO ;

LOCK 
INCLUDE DSK1.SAVESYS
' STARTER SAVESYS DSK3.BREAKOUT

DECIMAL

