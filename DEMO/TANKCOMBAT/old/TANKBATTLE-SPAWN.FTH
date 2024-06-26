\ COMBAT.FTH 
\  CCOMBAT HOST PROGRAM
\  Version 02.14.23 
\ by @VORTICON on Atariage.com 

\  PORTED & MODIFIED for Camel99 Forth  2023 Brian Fox 

NEEDS DUMP      FROM DSK1.TOOLS 
NEEDS BYTE      FROM DSK1.DATABYTE 
NEEDS RND       FROM DSK1.RANDOM 
NEEDS COLOR     FROM DSK1.GRAFIX 
NEEDS U.R       FROM DSK1.UDOTR   \ right justified numbers 
NEEDS HZ        FROM DSK1.SOUND 
NEEDS TASK:     FROM DSK1.MTASK99
NEEDS .TASKS    FROM DSK1.MTOOLS 
NEEDS MALLOC    FROM DSK1.MALLOC 

HEX 2000 H !  \ reset the heap for testing purposes 

\ create a task in heap, fork it, assign Execution token and run it
VARIABLE #TASKS 
: SPAWN  ( xt -- ) 
 USIZE MALLOC DUP >R FORK  R@ ASSIGN  R> WAKE 
 #TASKS 1+!  ;

\ HARD 1MS timer, 
DECIMAL
: 1MS
    16383 TMR!     \ max value in counter
    BEGIN          \ counts down
        TMR@ 16360 < \ wait for M this value
    UNTIL ;

: MS   0 ?DO  1MS PAUSE LOOP ;

\ Named characters make it easier to remember the shapes
DECIMAL 
128 CONSTANT BKG   ( background character)
BKG CONSTANT ---   ( alias for bkg character )
130 CONSTANT SQR 
131 CONSTANT BULLET 
132 CONSTANT BOX 

\ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

1  \ Color names from TI-Logo are more descriptive 
ENUM CLEAR  \ 1
ENUM BLACK
ENUM GREEN
ENUM LIME
ENUM BLUE
ENUM SKY
ENUM RED
ENUM CYAN  \ 8 
ENUM RUST
ENUM ORANGE
ENUM YELLOW
ENUM LEMON
ENUM OLIVE
ENUM PURPLE
ENUM GRAY
ENUM WHITE \ 16
DROP

\ Tank chars in different color sets 
136       CONSTANT TANK1  
TANK1 8 + CONSTANT TANK2   
TANK2 8 + CONSTANT TANK3   
TANK3 8 + CONSTANT TANK4   

\ --------------------------------------
\ user variables are local for each tank task
\ 6 VARIABLES define the tank 
HEX 
60 USER Y 
62 USER X 
64 USER DY       \ dx and dy can be accessed as a 2variable 
66 USER DX
68 USER PANZER   \ tank character 
70 USER MEMORY   \ pointer to circular buffer of headings for BETA chars 
72 USER TRIES    \ how many tries it takes to find a new heading 
42 USER HEADING  \ compass heading is the direction control 
\ --------------------------------------
\ words to access the tank data 
: XY@      ( -- x y) Y 2@  ;
: XY!      ( x y --) Y 2! ;
: POSITION ( -- Vaddr) XY@ >VPOS ;

: DXDY!    ( x y --) DY 2! ;
: DXDY@    ( -- X Y) DY 2@ ;

\ battlefield layout 
CREATE ScreenData
BYTE SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR
BYTE SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,SQR,SQR,SQR,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,SQR,SQR,SQR,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,SQR,SQR,SQR,---,---,---
BYTE ---,---,---,SQR,SQR,SQR,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,SQR,---,---,---,---,---
BYTE ---,---,---,---,---,SQR,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,SQR,SQR,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,SQR,SQR,---,---,SQR
BYTE SQR,---,---,---,SQR,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,SQR,---,---,---,SQR
BYTE SQR,---,---,---,SQR,---,---,SQR,SQR,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,SQR,SQR,---,---,SQR,---,---,---,SQR
BYTE SQR,---,---,---,SQR,---,---,SQR,SQR,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,SQR,SQR,---,---,SQR,---,---,---,SQR
BYTE SQR,---,---,---,SQR,---,---,SQR,SQR,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,SQR,SQR,---,---,SQR,---,---,---,SQR
BYTE SQR,---,---,---,SQR,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,SQR,---,---,---,SQR
BYTE SQR,---,---,SQR,SQR,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,SQR,SQR,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,SQR,---,---,---,---,---
BYTE ---,---,---,---,---,SQR,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,SQR,SQR,SQR,---,---,---
BYTE ---,---,---,SQR,SQR,SQR,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,SQR,SQR,SQR,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,SQR,SQR,SQR,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,---
BYTE ---,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,---,---,---,---,---,---,---,---,---,---,---,---,---,---,SQR
BYTE SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR
BYTE SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR,SQR
BYTE BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL
BYTE BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL ,BL

: .BATTLEFIELD ( -- ) ScreenData  VPG @  C/SCR @ VWRITE ;

\  Score display
DECIMAL 
VARIABLE P1SCORE  
VARIABLE P2SCORE 

: .P1SCORE   P1SCORE @  3 U.R ;
: .P2SCORE   P2SCORE @  4 U.R ;

: .SCORE
  2 23 AT-XY ." TANK 1: " .P1SCORE  ."     TANK 2: " .P2SCORE
;


\ ----------------------------
\ tank patterns for 8 compass headings 
HEX
CREATE NORTH[]    1010 , 547C , 7C7C , 7C44 , 
CREATE NE[]       0012 , 3478 , FE3C , 1810 ,
CREATE EAST[]     0000 , FC78 , 7F78 , FC00 , 
CREATE SE[]       1018 , 3CFE , 7834 , 1200 ,
CREATE SOUTH[]    447C , 7C7C , 7C54 , 1010 , 
CREATE SW[]       0818 , 3C7F , 1E2C , 4800 ,
CREATE WEST[]     0000 , 3F1E , FE1E , 3F00 ,
CREATE NW[]       0090 , 583C , FE78 , 3010 ,

DECIMAL 
CREATE TANKS ( -- addr) \ an array of patterns 
   NORTH[] , NE[] , EAST[] , SE[] ,
   SOUTH[] , SW[] , WEST[] , NW[] , 

\ select a pattern with a heading 
: ]TANK  ( heading -- Pattern-addr) CELLS  TANKS + @  ; 

: TANK-SHAPE ( heading -- ) \ set pattern based on HEADING variable
  \ RAM address   VDP address    bytes 
   ]TANK  PANZER @ CHARDEF ;

\ compass headings in clockwise order 
   0 CONSTANT NORTH
   1 CONSTANT NE
   2 CONSTANT EAST
   3 CONSTANT SE
   4 CONSTANT SOUTH
   5 CONSTANT SW
   6 CONSTANT WEST
   7 CONSTANT NW

\ EXPLOSION......................
HEX 
CREATE SHRAPNEL  \ :-) 
    0000 , 125C , 1E2C , 0000 , 
    0042 , 1498 , 0250 , 1400 ,
    1084 , 2200 , 1280 , 2400 ,
    2002 , 8001 , 0000 , 8104 ,
    0000 , 0000 , 0000 , 0000 ,

DECIMAL 
: EXPLODE ( char -- )
    4 NOISE GEN4 0 DB 25 MS 
    6 NOISE 
    ]PDT 
     5 0 DO
        PAUSE 
        I 8* SHRAPNEL +  OVER 8 VWRITE 
        40 MS 
        GEN4 I 4* DB 
    LOOP 
    GEN4 -28 DB 60 MS
    DROP  
    GEN4 MUTE 
;

\ random number functions 
: RNDX    ( -- x)  23 RND ;
: RNDY    ( -- y)  33 RND ;
: RANDOM  ( -- 0..7)  8 RND ; 
: RNDV    ( -- -1 0 1 ) 3 RND 1- ;

\ constant array of vectors, rotating clockwise 
CREATE VECTORS  ( -- addr) 
 \   Y    X  
 \  ---  ---
    -1 ,  0 ,  \ north 
    -1 ,  1 ,  \ NE 
     0 ,  1 ,  \ east 
     1 ,  1 ,  \ SE 
     1 ,  0 ,  \ south 
     1 , -1 ,  \ SW 
     0 , -1 ,  \ west 
    -1 , -1 ,  \ NW

\ return the correct vectors for a given heading 
: ]VECTOR ( heading -- dx dy)  2 CELLS *  VECTORS + 2@ ;

: ?LEGAL  ( n -- n ) DUP 8 0 WITHIN ABORT" Illegal heading" ;

HEX 
: REVERSE ( heading -- heading') 4 -  07 AND ;
DECIMAL 
: DIRECTION  ( heading  -- ) 
   ?LEGAL 
   DUP HEADING !        \ remember the new heading       
   DUP ]VECTOR  DXDY!   \ set tank's vectors for this heading 
       TANK-SHAPE       \ set the graphic for this heading 
;     

\ add coordinates to a vector 
: VECT+      ( x y dx dy -- x' y') >R ROT + SWAP R> +  ;

: PUT-CHAR   ( c -- ) POSITION VC! ;
: ERASE-TANK ( -- )   BKG PUT-CHAR ;
: .TANK      ( --) PANZER @ PUT-CHAR ;

: NEXT-POS   ( -- x y) XY@  DXDY@ VECT+  ;
: ADVANCE    ( -- )  ERASE-TANK   NEXT-POS XY!  .TANK ;


VARIABLE DELAY  50 DELAY ! 

: DECAY1 ( n -- )
    -10 DB DUP MS \ CALL SOUND(165,1165,0)::
    -18 DB DUP MS \ CALL SOUND(165,1165,8):: 
    -22 DB DUP MS \ CALL SOUND(165,1165,16)::
    -24 DB  MS \ CALL SOUND(165,1165,24)
  MUTE  ;

: BOINK          240 HZ  5 DECAY1 ; 
: BONK           120 HZ  8 DECAY1 ;

: CLEAR-AHEAD?  ( -- ?) NEXT-POS GCHAR  BKG = ;

\ put all tank chars in a counted string 
( a tank can't detect itself)
CREATE TANKCHARS  5 C,  TANK1 C, TANK2 C, TANK2 C, TANK3 C, TANK4 C, 

: SCANFOR ( Caddr -- n)  COUNT ROT SCAN NIP ;

\ now we can test an enemy char with SCAN 
: ENEMY? ( char -- 0|n ) TANKCHARS  SCANFOR ;

: CLIP    ROT MIN MAX ;
: RND-HEADING  8 RND DIRECTION ;

: ALPHA-TANK ( --)
    BEGIN 
     .TANK 
      CLEAR-AHEAD? 
      IF 
        ADVANCE 
        TRIES OFF 
      ELSE 
        GEN2 BONK  
        RND-HEADING 
        TRIES 1+! 
      THEN 
      DELAY @ MS 
    AGAIN 
;

: HUNTER-TANK ( --)
    BEGIN 
      PAUSE 
      .TANK 
      CLEAR-AHEAD? 
      IF 
        ADVANCE 
        TRIES OFF 
      ELSE 
        NEXT-POS GCHAR 
        DUP ENEMY? 
        IF  EXPLODE MUTE 
            P1SCORE 1+! 
        ELSE 
            DROP GEN1 BOINK  
        THEN 
        RND-HEADING 
        TRIES 1+! 
      THEN 
      DELAY @ MS 
    AGAIN 
;

: INITS
   CLEAR
   RANDOMIZE
   S" 0000000000000000" BKG    CALLCHAR 
   S" FFFFFFFFFFFFFFFF" SQR    CALLCHAR 
   S" 0000001818000000" BULLET CALLCHAR 
   S" FFFFC3C3C3C3FFFF" BOX    CALLCHAR 
    BKG SET# YELLOW RED COLOR 
    PURPLE SCREEN
   .BATTLEFIELD .SCORE
;

: GOOD-GUY
   GEN1  ( set the sound generator for this task )
   RND-HEADING  
   TANK1 PANZER ! 
   15 12 XY! 
   PANZER @ SET# BLACK RED COLOR 
   HUNTER-TANK ;

: BAD-GUY1 
   GEN2
   TANK2 PANZER ! 
   PANZER @ SET# GRAY RED COLOR 
   15 12 XY! 
   RND-HEADING 
   ALPHA-TANK ;

: BAD-GUY2
   GEN2 
   TANK3 PANZER ! 
   PANZER @ SET# LIME RED COLOR 
   15 12 XY! 
   RND-HEADING  
   ALPHA-TANK ;

: BAD-GUY3 ( -- )
   TANK4 PANZER ! 
   GEN2 
   PANZER @ SET# BLUE RED COLOR 
   15 12 XY! 
   RND-HEADING 
   ALPHA-TANK ;

HEX 

83D6 CONSTANT ALWAYS \ :-) screen time-out timer
   ' BAD-GUY1 SPAWN
   ' BAD-GUY2 SPAWN
 
: BAD-GUYS  0 DO ['] BAD-GUY3 SPAWN  LOOP ;

DECIMAL 
4 BAD-GUYS 

: KILLALL    
    USIZE #TASKS @ *  MFREE
    #TASKS OFF 
    INIT-MULTI ;

: RUN  
    INITS  
    ALWAYS ON 
    2000 H ! 
    MULTI  

\ console task just updates the score and waits for break key 
    BEGIN 
      .SCORE 
       PAUSE 
       ?TERMINAL 
    UNTIL
    SINGLE SILENT  
    KILLALL 
    PAGE 
    ABORT  
;

12 DELAY ! 

