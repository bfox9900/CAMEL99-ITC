\ COMBAT.FTH 
NEEDS DUMP      FROM DSK1.TOOLS 
NEEDS BYTE      FROM DSK1.DATABYTE 
NEEDS RND       FROM DSK1.RANDOM 
NEEDS COLOR     FROM DSK1.GRAFIX 
NEEDS U.R       FROM DSK1.UDOTR   \ right justified numbers 
NEEDS HZ        FROM DSK1.SOUND 

\  CCOMBAT HOST PROGRAM
\  Version 02.14.23 
\ by @VORTICON on Atariage.com 

\  PORTED & MODIFIED for Camel99 Forth  2023 Brian Fox 


\ Named characters make it easier to remember the shapes
DECIMAL 
128 CONSTANT BKG   ( background character)
BKG CONSTANT ---   ( alias for bkg character )
129 CONSTANT TANK1
130 CONSTANT SQR 
131 CONSTANT BULLET 
132 CONSTANT BOX 

TANK1 8 + CONSTANT TANK2 \ different color set 

\ --------------------------------------
\ user variables are local for each tank task
\ 6 VARIABLES define the tank 
HEX 
60 USER Y 
62 USER X 
64 USER DY      \ dx and dy can be accessed as a 2variable 
66 USER DX
68 USER PANZER   \ tank character 
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
   ]TANK         PANZER @ ]PDT   8  VWRITE ;

\ compass headings in clockwise order 
   0 CONSTANT NORTH
   1 CONSTANT NE
   2 CONSTANT EAST
   3 CONSTANT SE
   4 CONSTANT SOUTH
   5 CONSTANT SW
   6 CONSTANT WEST
   7 CONSTANT NW


\ random number funcions 
: RNDX    ( -- x)  23 RND ;
: RNDY    ( -- y)  33 RND ;
: RNDHEAD ( -- 0..7)  8 RND ; 
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
    -1 , -1 , \ NW

\ return the correct vectors for a given heading 
: ]VECTOR ( heading -- dx dy)  2 CELLS *  VECTORS + 2@ ;

: ?LEGAL  ( n -- n ) DUP 8 0 WITHIN ABORT" Illegal heading" ;

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


\ Radar sound routine
: DECAY ( n -- )
  -10 DB DUP MS \ CALL SOUND(165,1165,0)::
  -18 DB DUP MS \ CALL SOUND(165,1165,8):: 
  -22 DB DUP MS \ CALL SOUND(165,1165,16)::
  -24 DB  MS \ CALL SOUND(165,1165,24)
   MUTE  ;

: RADAR    GEN1 1165 HZ  90 DECAY ; 
: BOINK    GEN1  200 HZ  40 DECAY ; 

: CLEAR-AHEAD?  ( -- ?) NEXT-POS GCHAR  BKG = ;

: ALPHA-TANK ( x y --)
    XY!  
    BEGIN 
      .TANK 
      CLEAR-AHEAD? 
      IF 
        ADVANCE 
      ELSE 
        BOINK  RNDHEAD DIRECTION  
      THEN 
      120 MS 
      ?TERMINAL 
    UNTIL 
;

\  Subroutines section

\  Score display
VARIABLE P1SCORE  
VARIABLE P2SCORE 

: .P1SCORE   P1SCORE @  3 U.R ;
: .P2SCORE   P2SCORE @  4 U.R ;

: SCORE:
    2 23 AT-XY ." TANK 1: " .P1SCORE  ."     TANK 2: " .P2SCORE
;

: INITS
   CLEAR
   RANDOMIZE
   S" 0000000000000000" BKG CALLCHAR 
   S" FFFFFFFFFFFFFFFF" SQR    CALLCHAR 
   S" 0000001818000000" BULLET CALLCHAR 
   S" FFFFC3C3C3C3FFFF" BOX    CALLCHAR 

   TANK1 PANZER !  
   15 12 XY! 
   NORTH DIRECTION 

   14 SCREEN
   BKG SET#  DUP 3 +  11 9 COLORS
   .BATTLEFIELD SCORE:  ;

: RUN    INITS   15 12 ALPHA-TANK ;




\  Scan for enemy tank and determine LOS
\ SUB SCAN(DIR,XC,YC,XP,YP,LFLAG)

\  Line of sight routine
\ SUB LOS(OX1,OY1,X2,Y2,FLAG)

\  Gun fire subroutine
\ SUB FIRE(S,X,Y,DIR,FLAG)

\  Tank displacement routine
\  SUB DELTA(DIR,DX,DY)
