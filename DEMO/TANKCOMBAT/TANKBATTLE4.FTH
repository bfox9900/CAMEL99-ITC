\ COMBAT.FTH  multi-tasking tank simulation for Camel99 Forth Brian Fox 
\  Based on CCOMBAT HOST PROGRAM
\  Version 02.14.23 
\  by @VORTICON on Atariage.com 

\  Heavily modified for Camel99 Forth  2023 Brian Fox 

\ NEEDS DUMP      FROM DSK1.TOOLS 
NEEDS BYTE      FROM DSK1.DATABYTE 
NEEDS RND       FROM DSK1.RANDOM 
NEEDS COLOR     FROM DSK1.GRAFIX 
NEEDS SPRITE    FROM DSK1.DIRSPRIT 
NEEDS U.R       FROM DSK1.UDOTR   \ right justified numbers 
NEEDS HZ        FROM DSK1.SOUND 
NEEDS TASK:     FROM DSK1.MTASK99
NEEDS MALLOC    FROM DSK1.MALLOC 
NEEDS MARKER    FROM DSK1.MARKER 
NEEDS VALUE     FROM DSK1.VALUES 

MARKER /ALPHA 

HEX 
: NEW-HEAP  2000 H !   H @ 2000 0 FILL ; \ reset & erase heap 

\ create a task in heap, fork it, assign Execution token
: SPAWN ( xt -- pid) USIZE MALLOC DUP>R FORK R@ ASSIGN R> ;

\ spawn n NULL tasks and compile the PIDs sequentially in memory 
: TASKS ( n -- ) 0 DO  ['] PAUSE SPAWN ,  LOOP ;

0 VALUE TASK-TBL  

\ array of process IDs 
: ]PID ( n -- PID ) CELLS TASK-TBL + @ ;

\ Enumerate Tank chars in different color sets 
DECIMAL
: TANKCHAR:  DUP  CONSTANT  8 + ; 

136 \ 1st tank character 
TANKCHAR: TANK0   TANKCHAR: TANK1     TANKCHAR: TANK2
TANKCHAR: TANK3   TANKCHAR: TANK4     TANKCHAR: TANK5
TANKCHAR: TANK6   TANKCHAR: TANK7     TANKCHAR: TANK8
TANKCHAR: TANK9   TANKCHAR: TANK10    TANKCHAR: TANK11
TANKCHAR: TANK12  TANKCHAR: TANK13    TANKCHAR: TANK14
TANKCHAR: TANK15
DROP 

\ put all tank chars in a counted string for searching with SCAN 
CREATE TANKCHARS ( -- Caddr)
  16 C,  
  TANK0  C, TANK1  C, TANK2  C, TANK3  C,
  TANK4  C, TANK5  C, TANK6  C, TANK7  C,
  TANK8  C, TANK9  C, TANK10 C, TANK11 C, 
  TANK12 C, TANK13 C, TANK14 C, TANK15 C,  

\ compute process number (index) from a tank's ASCII character 
: 8/    3 RSHIFT ;
: >TASK# ( ascii -- n) 8/ [ TANK0 SET# ] LITERAL - ;

\ Get PID from the tank character argument 
\ This allows us to send messages to a tank when we detect it
\ in the battlefield 
: PID ( tank -- PID ) >TASK# ]PID ;

\ Named characters make it easier to remember the shapes
DECIMAL 
128 CONSTANT BKG   ( background character)
BKG CONSTANT ---   ( alias for bkg character )
130 CONSTANT SQR 
131 CONSTANT BULLET 
132 CONSTANT BOX 
001 CONSTANT DOT   ( sprite radar scanner )

\ Enumerate colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

\ Color names from TI-Logo are more descriptive 
1  
ENUM TRANS    ENUM BLACK    ENUM GREEN    ENUM LIME     
ENUM BLUE     ENUM SKY      ENUM RED      ENUM CYAN     
ENUM RUST     ENUM ORANGE   ENUM YELLOW   ENUM LEMON
ENUM OLIVE    ENUM PURPLE   ENUM GRAY     ENUM WHITE 
DROP


\ --------------------------------------
\ user variables are local for each tank task
HEX 
30 USER KILLS     \ 
44 USER HEADING   \ compass heading is the direction control 
\ 46 USER TPAD    \ defined in Kernel
48 USER Y 
4A USER X 
4C USER DY       \ dx and dy can be accessed as a 2variable 
4E USER DX
50 USER PANZER   \ tank character 
52 USER SPEED   
54 USER MEMORY   \ pointer to circular buffer of headings for BETA chars  
56 USER MAILBOX  \ one mailbox per task
58 USER BRAIN   
60 USER SPRITE#  \ sprite # of the radar dot  

\ --------------------------------------
\ words to access the tank data 
: XY@      ( -- x y) Y 2@  ;
: XY!      ( x y --) Y 2! ;
: POSITION ( -- Vaddr) XY@ >VPOS ;

: DXDY!    ( x y --) DY 2! ;
: DXDY@    ( -- X Y) DY 2@ ;

\ random number functions 
: RNDX    ( -- x)  23 RND ;
: RNDY    ( -- y)  33 RND ;
: RANDOM  ( -- 0..7) 8 RND ; 
: RNDV    ( -- -1|0|1 ) 3 RND 1- ; \ random vector 


\ battlefield layout 
CREATE BattleField
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
BYTE BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL
BYTE BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL

: .BATTLEFIELD ( -- ) BattleField  VPG @  C/SCR @ VWRITE ;

\  Score display
DECIMAL 
: .KILLS ( pid -- )  KILLS LOCAL @ 2 .R ;

: CLRLN   0 23 >VPOS C/L@ BL VFILL ;

: .SCORE   
  0 23 AT-XY ." Hunter:"   0 ]PID .KILLS 
  2 SPACES   ." STALKER:"  1 ]PID .KILLS ;

\ -------------------------------------------
\ tank patterns for 8 compass headings 

HEX
CREATE NORTH$    1010 , 547C , 7C7C , 7C44 , 
CREATE NE$       0012 , 3478 , FE3C , 1810 ,
CREATE EAST$     0000 , FC78 , 7F78 , FC00 , 
CREATE SE$       1018 , 3CFE , 7834 , 1200 ,
CREATE SOUTH$    447C , 7C7C , 7C54 , 1010 , 
CREATE SW$       0818 , 3C7F , 1E2C , 4800 ,
CREATE WEST$     0000 , 3F1E , FE1E , 3F00 ,
CREATE NW$       0090 , 583C , FE78 , 3010 ,

\ Put tank patterns in an array to access them numerically 
DECIMAL 
CREATE TANKS ( -- addr) 
   NORTH$ , NE$ , EAST$ , SE$ ,
   SOUTH$ , SW$ , WEST$ , NW$ , 

\ compass headings in clockwise order for reference 
\   0 CONSTANT NORTH
\   1 CONSTANT NE
\   2 CONSTANT EAST
\   3 CONSTANT SE
\   4 CONSTANT SOUTH`
\   5 CONSTANT SW
\   6 CONSTANT WEST
\   7 CONSTANT NW

\ select a pattern with a heading 
: ]TANK  ( heading -- Pattern-addr) CELLS TANKS + @  ; 

: TANK-SHAPE ( heading -- ) \ set pattern based on HEADING variable
  \ RAM address   VDP address   bytes 
    ]TANK        PANZER @ ]PDT   8  VWRITE ;


\ double constant array of vectors, rotating clockwise like headings 
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

: ?HEADING  ( n -- n ) DUP 8 0 WITHIN ABORT" Illegal heading" ;

DECIMAL 
: DIRECTION  ( heading  -- ) 
   ?HEADING 
   PAUSE 
   DUP HEADING !        \ remember the new heading       
   DUP ]VECTOR  DXDY!   \ set tank's vectors for this heading 
       TANK-SHAPE       \ set the graphic for this heading 
;     

\ words to change the current heading 
: REVERSE ( heading -- heading') 4 -  07 AND ;
: -90DEG  ( heading -- -90 )     2-   07 AND ;
: +90DEG  ( heading -- +90 )     2+   07 AND ;
: LEFT    ( heading -- -45 )     1-   07 AND ;
: RIGHT   ( heading -- -45 )     1+   07 AND ;

\ EXPLOSION......................
HEX 
CREATE SHRAPNEL  \ :-) 
    0000 , 125C , 1E2C , 0000 , 
    0042 , 1498 , 0250 , 1400 ,
    1084 , 2200 , 1280 , 2400 ,
    2002 , 8001 , 0000 , 8104 ,
    0000 , 0000 , 0000 , 0000 ,

: ]SHRAP  8* SHRAPNEL +    ;

DECIMAL 
: EXPLODE ( char -- )
    4 NOISE GEN4 0 DB 25 MS 
    6 NOISE 10 MS 
    ]PDT
     5 0 DO
        PAUSE 
        I ]SHRAP OVER 8 VWRITE 
        80 MS 
        I 4* DB 
    LOOP 
    DROP  
   -26 DB 60 MS 
   SILENT 
;

\ add coordinates to a vector 
: VECT+      ( x y dx dy -- x' y') >R ROT + SWAP R> + ;

: PUT-CHAR   ( c -- ) PAUSE POSITION VC! ;
: ERASE-TANK ( -- )   BKG PUT-CHAR ;
: .TANK      ( --)  PANZER @ PUT-CHAR ;
: XY.TANK ( x y --)  XY!  .TANK ;

\ managing tank location in x,y or VDP address form 
: NEXT-XY    ( x y -- x' y') DXDY@ VECT+ ; 
: FWD        ( -- x y) XY@ NEXT-XY ;  

: RANGE      ( x y -- x y) 0 DO NEXT-XY LOOP ;
: 3AHEAD     ( x y -- x y) NEXT-XY NEXT-XY ;

: VDP>XY     ( Vaddr -- X Y) C/L@ /MOD  ;
: NEXT-ADDR  ( Vaddr -- Vaddr') VDP>XY FWD >VPOS ;

\ radar sweep in a circle at range distance. Sprite used to see the scanner 
DECIMAL 
  S" 0000001000000000" 1 CALLCHAR 
: >PIXXY  ( x y -- px py) 8* SWAP 8* SWAP ;
: PLOT    ( x y -- ) >PIXXY SPRITE# @ LOCATE ;

: ADVANCE    ( -- )  
  ERASE-TANK   
  FWD XY.TANK 
  SPEED @ MS 
;

: DECAY1 ( n -- )
    -10 DB DUP TICKS
    -18 DB DUP TICKS 
    -22 DB DUP TICKS 
    -26 DB     TICKS 
    MUTE
;

: BOINK       900 HZ  500 DECAY1   ; 
: BONK        120 HZ  500 DECAY1   ;

\ SCAN is a fast word to find a character 
: SCANFOR ( Caddr -- n)  COUNT ROT SCAN NIP ;

\ now we can test an enemy char with SCAN 
: ENEMY? ( char -- 0|n ) TANKCHARS  SCANFOR ;

: RND-HEADING   8 RND DIRECTION ;
: GO-LEFT       HEADING @  LEFT DIRECTION ;
: GO-RIGHT      HEADING @  RIGHT DIRECTION ;
: TURN-AROUND  HEADING @  REVERSE DIRECTION ;

: THINK   BRAIN PERFORM ;

: CLEAR-AHEAD? ( -- ?)  XY@ NEXT-XY GCHAR BKG = ;

DECIMAL 
: ALPHA-MIND \ common logic for simple creatures 
    RND-HEADING     
    15 12 XY.TANK 
    BEGIN 
      BEGIN 
        CLEAR-AHEAD?
      WHILE 
        ADVANCE  
        THINK    \ this can RUN anything 
      REPEAT 
      BONK MUTE 
      RND-HEADING 
    AGAIN 
;

: ALPHA-TANK ( --) 
    100 SPEED !  
    GEN2 MUTE 
    PANZER @ SET# GRAY RED COLOR 
    ['] PAUSE BRAIN ! 
    ALPHA-MIND  
;     

DECIMAL 
: %CHANCE ( n -- ?) 100 RND > ;  
: FREEZE  ( -- ) 2500 RND 500 + MS ;

: RABBIT-THOUGHTS 
    MUTE 
    7  %CHANCE IF GO-LEFT            EXIT THEN 
    7  %CHANCE IF GO-RIGHT           EXIT THEN 
    1  %CHANCE IF TURN-AROUND        EXIT THEN 
    2  %CHANCE IF FREEZE             EXIT THEN 
    5  %CHANCE IF 50 RND 5 + SPEED ! EXIT THEN 
; 

: RABBIT-TANK ( --) 
    100 SPEED !  
    GEN3 MUTE 
    PANZER @ SET# BLUE RED COLOR 
    15 12 XY.TANK 
    ['] RABBIT-THOUGHTS BRAIN ! 
    ALPHA-MIND 
;

: DESTROY ( char -- )
      DUP 
      PID SLEEP           \ put the task to sleep to stop it
      EXPLODE             \ blow up the enemy char
      BKG FWD >VPOS VC!   \ erase from battlefield 
;

: PIXELS ( x y -- px py) 8* SWAP 8* SWAP ;
: POINTER   XY@ FWD PIXELS SPRITE# @ LOCATE ;

: ALPHA-HUNTER ( --)
    95 SPEED ! 
    GEN1 MUTE ( set the sound generator for this task )
    15 12 XY! 
    RND-HEADING  
    PANZER @ SET# BLACK RED COLOR 
    0 SPRITE# ! 
 ( char colr   x    y   sp# )
    1   LIME  255  255 SPRITE# @ SPRITE
    ['] POINTER BRAIN ! 
    BEGIN 
      PAUSE 
      XY@ NEXT-XY GCHAR
      DUP ENEMY? IF DESTROY  KILLS 1+!  ELSE 
      
      DUP BKG =  IF DROP ADVANCE        ELSE 
                 \ default actions     
                    BOINK  MUTE 
                    RND-HEADING 
                    DROP
      THEN THEN 
      MUTE 
    AGAIN 
;

: FIND-A-WALL ( -- )
    BEGIN 
      CLEAR-AHEAD?
    WHILE 
      ADVANCE  
    REPEAT 
;

: GO-AND-HIDE ( -- ) RND-HEADING  FIND-A-WALL  TURN-AROUND ;

: STALKER ( -- ) 
\ finds a hiding place and shoots what comes past
    100 SPEED ! 
    GEN2 MUTE 
    PANZER @ SET#  GREEN RED COLOR 
    15 12 XY.TANK
    GO-AND-HIDE 
    BEGIN   
      PAUSE 
      XY@ NEXT-XY GCHAR 
      DUP ENEMY? 
      IF  DESTROY  KILLS 1+!
      ELSE DROP  
      THEN MUTE 

      \ every so often move to a new location
      10000 RND 5 < IF GO-AND-HIDE THEN   
         
    AGAIN 
;

: TANK-BUILDER ( xt tank# --) 
    DUP DUP PID PANZER LOCAL ! 
            PID ASSIGN PAUSE ;

\ assign the configured tank programs to tasks
: CREATE-TANKS 
  ['] ALPHA-HUNTER TANK0 TANK-BUILDER 
  ['] STALKER      TANK1 TANK-BUILDER
  
  ['] ALPHA-TANK  TANK2  TANK-BUILDER
  ['] ALPHA-TANK  TANK3  TANK-BUILDER
  ['] ALPHA-TANK  TANK4  TANK-BUILDER
  ['] ALPHA-TANK  TANK5  TANK-BUILDER
  ['] ALPHA-TANK  TANK6  TANK-BUILDER
  ['] ALPHA-TANK  TANK7  TANK-BUILDER
  ['] ALPHA-TANK  TANK8  TANK-BUILDER

  ['] RABBIT-TANK TANK9  TANK-BUILDER
  ['] RABBIT-TANK TANK10 TANK-BUILDER
  ['] RABBIT-TANK TANK11 TANK-BUILDER

  ['] ALPHA-TANK  TANK12  TANK-BUILDER
  ['] ALPHA-TANK  TANK13  TANK-BUILDER
  ['] ALPHA-TANK  TANK14  TANK-BUILDER
  ['] ALPHA-TANK  TANK15  TANK-BUILDER
;

: DRAW-SCREEN 
    CLEAR
    RANDOMIZE
    S" 0000000000000000" BKG    CALLCHAR 
    S" FFFFFFFFFFFFFFFF" SQR    CALLCHAR 
    S" 0000001818000000" BULLET CALLCHAR 
    S" FFFFC3C3C3C3FFFF" BOX    CALLCHAR 
    S" 0000001000000000" DOT    CALLCHAR 
    BKG SET# YELLOW RED COLOR 
    PURPLE SCREEN
   .BATTLEFIELD 
;

HEX 
83D6 CONSTANT ALWAYS   \ :-) screen time-out timer

DECIMAL
: PROMPT  0 23 AT-XY  VPOS C/L@  BL VFILL ;

\ scan each task to see if it is still awake
: .#LIVE ( -- n) 
  0  
  16 0 DO  
    PAUSE 
     I ]PID TFLAG LOCAL @
     IF 1+ THEN 
    PAUSE 
  LOOP 
  DUP 24 23 AT-XY ." LIVE:" 2 .R 
;

DECIMAL 
: RESTARTS ( n -- ) 
  2+  2 DO    \ skip first 2 tanks, hunter and stalker 
      PAUSE  
      I ]PID  RESTART  
      800 MS 
      .#LIVE 
    LOOP ;

: BUILD-TANKS     
 HERE                 \ task table will use memory at HERE 
  NEW-HEAP 
  16 TASKS TO TASK-TBL \ Spawn 16 tasks. Assign HERE to task table
                            
  CREATE-TANKS 

  MULTI  
  PROMPT ." Creating Tank processes"
  12 RESTARTS          \ the "prey" 
  3000 MS 

  PROMPT ." Stalker tank activated"
  TANK1 PID RESTART .#LIVE 
  2000 MS 

  PROMPT ." Hunter tank activated"
  TANK0 PID RESTART .#LIVE   \ start the hunter first
  2000 MS
; 

\ updates the score and waits for break key 
: MONITOR_ACTIVITY
    CLRLN 
    BEGIN 
      ALWAYS ON 
      .SCORE  
      PAUSE 
      ?TERMINAL .#LIVE 1 = OR
    UNTIL
    800 MS 
    BEEP CLRLN 0 23 AT-XY  ." Simulation completed"
    2000 MS 
;

: RUN  
  BEGIN 
    DECIMAL 
    INIT-MULTI  DRAW-SCREEN  BUILD-TANKS    
    MONITOR_ACTIVITY
    SINGLE SILENT  
    PROMPT ." Exit simulation?" 
    KEY [CHAR] Y =
  UNTIL 
  BYE
;

\ this words starts the binary program 
: STARTER   WARM  GRAPHICS  RUN   ABORT ;

  LOCK
  INCLUDE DSK1.SAVESYS 
' STARTER  SAVESYS DSK3.ALPHAHUNT



