\ BILLYBALL.fTH  mulit-tasking game demo  June 2024  Brian Fox 

\ Inpired by work on XB256 by @Retrospect on atariage.com  Nov 1 2021
\ Graphics characters are taken directly from THE BASIC program 

\ This program combines many features of Camel99 Forth. 
\ 1. Multi-tasking to manage animated sprites 
\    with dynamic task creation at game startup 
\ 2. Automotion to free the game from moving sprites manually
\ 3. Assembly language Joystick code for fast responses
\ 4. Fast coincidence code mixes Assembler and Forth
\ 5. HEX#, number compiler for long pattern strings 
\ 6. QUIT-ON QUIT-OFF to enable/disable FCTN QUIT key 

\ INCLUDE DSK1.TOOLS    \ DEBUG ONLY
INCLUDE DSK1.MARKER
INCLUDE DSK1.MALLOC
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND
INCLUDE DSK1.DIRSPRIT  
INCLUDE DSK1.AUTOMOTION 
INCLUDE DSK1.MTASK99
INCLUDE DSK1.RANDOM
INCLUDE DSK1.JOYST 
INCLUDE DSK1.UDOTR 
INCLUDE DSK1.VALUES 

 1 CONSTANT Transparent
 2 CONSTANT Black
 3 CONSTANT Green
 5 CONSTANT Blue
 7 CONSTANT DKRed 
 8 CONSTANT Cyan 
 9 CONSTANT Red
11 CONSTANT Yellow
16 CONSTANT White

\ ***********************
\ task management 
\ ***********************
\ NEW-TASK returns a Process ID (PID) (ie: an address) in LOW RAM HEAP 
\ USIZE = 192 bytes, for workspace, task variables and 2 small stacks 
: NEW-TASK ( -- pid) USIZE MALLOC DUP FORK ;


\ ******************************************
\ reset the HEAP memory pointer before allocating memory 
HEX 
: RESET-HEAP   2000 H ! ;

\ QUIT key enable/disable
HEX
: QUIT-OFF ( -- ) 83C2 DUP C@ 70 AND 10 OR SWAP  C! ;
: QUIT-ON  ( -- ) 83C2 DUP C@ 60 AND SWAP C! ;

DECIMAL 
6 CONSTANT REDO \ fctn 8 KEY 

: WAIT-FOR-QUIT   
  QUIT-ON  
  6 14 AT-XY ." PRESS FCTN REDO (8)"
  6 15 AT-XY ."   to play again"
  BEGIN  
    KEY? REDO = 
    IF  COLD 
    THEN PAUSE  
  AGAIN ;   

\ *******************************************
\ task PIDs are saved in VALUEs
DECIMAL
0 VALUE JOB1   0 VALUE JOB2 
0 VALUE JOB3   0 VALUE JOB4 
0 VALUE JOB5   0 VALUE JOB7 
0 VALUE SOUND 

\ allocate memory in HEAP for all the tasks in the game
: CREATE-TASKS 
  RESET-HEAP 
  NEW-TASK TO JOB1    \ Billy ball rotator
  NEW-TASK TO JOB2    \ Bill ball  mover
  NEW-TASK TO JOB3    \ Bobby ball rotator
  NEW-TASK TO JOB4    \ Bobby ball mover
  NEW-TASK TO JOB5    \ cannon
\ NEW-TASK JOB6    \ (Unused) former Asteroid mover
  NEW-TASK TO JOB7    \ Asteroid spinner   
  NEW-TASK TO SOUND   \ sound code SOUND 
;

\ stop a running task and give control to next task 
: STOP  ( pid -- ) SLEEP PAUSE ; 

\ ***********************
\ Local variables for each task 
\ ***********************
HEX
50 USER SPIN   \ user variable for rotation speed
52 USER SPEED  \ speed of motion


\ ***********************
\ Fast mulitplier: R4 5 SLA, 
\ ***********************
HEX
CODE 32* ( n -- n')  0A54 , NEXT, ENDCODE  

\ ***********************
\ CHAR DEFINITION HELPERS
\ ***********************
DECIMAL
\ def 2 chars at once (32 bytes) 
: CHARDEF32 ( data[] ascii# -- ) ]PDT 32 VWRITE ; 

\ COMPILER Extension: Makes stealing BASIC code easier :-)
\ Convert long text string to 16 bit HEX numbers at COMPILE time 
\ Compile each number into memory sequentially
: HEX#, ( addr len --)
        BASE @ >R        \ save radix
        HEX              \ converting string to hex numbers
        BEGIN DUP
        WHILE            \ while len<>0
           OVER 4        \ used 4 digits from left end of string
           NUMBER? ?ERR  \ convert string to number
           ,             \ compile the integer into memory
           4 /STRING     \ cut 4 digits off left side of string
        REPEAT          
        2DROP
        R> BASE !        \ restore radix
;


\ *********************
\ *     ASTEROIDS     *
\ *********************
DECIMAL
CREATE ASTEROIDS
S" 000F191032434964504C23100C0700000000C020501098CC1272941CF0000000" HEX#,
S" 000000050A10121410181C13110D03000000F008104844CC9A12648418600000" HEX#,
S" 00000001020509181F10100E07000000000000F02804E4063EE2020CF0000000" HEX#,
S" 00000000031C382E212018070000000000000070888C5262828C90E000000000" HEX#,
S" 0000000007182F2524150E000000000000000000E01078C4042CD80000000000" HEX#,
S" 00000000000F18282F28311E0000000000000000E05844C43C0428F000000000" HEX#,
S" 000000000304041D161414181108070000000000789412729A06024438C08000" HEX#,

\ array of 7 asteroid patterns (0..6)
: ]ASTEROID ( n -- addr) 32* ASTEROIDS + ; 


: ROCK-SPINNER ( char speed -- )
    SPIN !
    BEGIN
      7 0 
      DO
        I ]ASTEROID OVER CHARDEF32
        SPIN @ MS
     \   PAUSE
      LOOP
    AGAIN ;


\ ***********************
\ * BALL ANIMATION DEFS *
\ ***********************
\ Compile contiguos data for each frame of Ball animation
CREATE BALLS ( patterns for 23 chars )
S" 00030F1F3F3C787A787F7F3C3E1F0F0300E0F8FCFE9E8FAF8FFFFF1E3EFCF8E0" HEX#,
S" 00030F1F3F397175717F7F383C1F0F0300E0F8FCFE3E1F5F1FFFFF3E7EFCF8E0" HEX#,
S" 00030F1F3F32626A627F7F30381F0F0300E0F8FCFE7E3FBF3FFFFF7EFEFCF8E0" HEX#,
S" 00030F1F3F244455447F7F20311F0F0300E0F8FCFEFE7F7F7FFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F09082A087F7F01231F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F131155117F7F03071F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F27232B237F7F070F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F0F4757477F7F0F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F1F0F2F0F7F7F1F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F1F1F5F1F7F7F3F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,

\ 4 duplicates of the backside make the spin timing look correct 
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFEFFFFFFFFFFFEFEFCF8E0" HEX#,

S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFCFCFDFCFFFFFEFEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEFCF8FAF8FFFFFCFEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEF8F1F5F1FFFFF8FEFCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEF2E2EAE2FFFFF0F8FCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEE4C4D5C4FFFFE0F0FCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFEC888AA88FFFFC0E2FCF8E0" HEX#,
S" 00030F1F3F3F7F7F7F7F7F3F3F1F0F0300E0F8FCFE92115511FFFF82C6FCF8E0" HEX#,
S" 00030F1F3F3F7E7E7E7F7F3F3F1F0F0300E0F8FCFE2623AB23FFFF068EFCF8E0" HEX#,
S" 00030F1F3F3E7C7D7C7F7F3E3F1F0F0300E0F8FCFE4E475747FFFF0E1EFCF8E0" HEX#,

\ expose BALLS as an array of 32 byte records
\ these patterns are written to VDP continuosly to rotate the faces
\ Animate the BALL by sequencing from 0 ]BALL  to 22 ]BALL OR reverse
: ]BALL ( n -- addr )  32* BALLS +  ;


\ character patterns are recorded in RAM as integers using a string and HEX#, 
\ This is smaller that storing a string in the program 
CREATE EXPLOSION
\ S" 0030787C3E1C0070FCF8F83103030100000E1E1C382000071F0F8680C0E08000" HEX#,
 S" 0004281208294723" HEX#,
 S" 4703290026100A00" HEX#, 
 S" 0000288A24508AC0" HEX#, 
 S" C0E2942046104800" HEX#, 

\ ********************************
\ * BILLY BALL'S MAGICAL MISSILE *
\ ********************************
CREATE COMET 
S" 0000000000000211AF02000000000000000000000034FDDFEFF6280000000000" HEX#, 


\ ************************
\ *      THE GROUND      *
\ ************************
251 CONSTANT DIRT.CHAR
CREATE EARTH
S" 10183C3C7E7EFFFF0000001010387CFF0000000000000FFF08080818387C7EFF" HEX#,

: .DIRT 
  DIRT.CHAR SET# 15 1 COLOR 
  3 18 252 26 HCHAR 
  2 19 252 28 HCHAR 
  1 20 252 30 HCHAR 
  0 21 252 32 HCHAR  
;

DECIMAL
\ Characters used 
128 CONSTANT Billy
132 CONSTANT Bobby
136 CONSTANT Missle
140 CONSTANT Rock

\ ********************************
\ put patterns in VDP RAM 
\ *****************************
: WRITE-PATTERNS 
  EARTH DIRT.CHAR CHARDEF32
  COMET Missle CHARDEF32
;


\ sprite numbers begin with #
 0  CONSTANT #Rock 
 1  CONSTANT #Rock2 
 2  CONSTANT #Rock3 
 3  CONSTANT #Rock4 

 5  CONSTANT #Bill
 6  CONSTANT #Bob
 7  CONSTANT #Weapon

\ *****************************
\ MAKE SPRITES
\ *****************************
: CREATE_SPRITES 
( char      colr    x   y   sp# -- )
  Rock      DKRed  127 188 #Rock    SPRITE 
  Rock 1+   Red    112 189 #Rock2   SPRITE 
  Rock 2+   Green  134 192 #Rock3   SPRITE 
  Rock 3 +  Yellow 106 190 #Rock4   SPRITE 

  Billy     White   10  10 #Bill    SPRITE
  Bobby     Blue   215  10 #Bob     SPRITE
  Missle    2      20  20 #Weapon  SPRITE
; 


\ *****************************
\ Multi-Task actions must be in an endless loop. Control with WAKE/SLEEP
\ *****************************

DECIMAL
: SPIN-RATE ( n spr# -- ) SPIN LOCAL ! ;

: ROTATOR ( char speed -- )
    SPIN !
    BEGIN
      23 0 
      DO
        PAUSE
        I ]BALL OVER CHARDEF32
        SPIN @ MS
      LOOP
    AGAIN ;


DECIMAL
: DELAY  0 ?DO  PAUSE LOOP ;

: BOUNCER ( spr# speed --)
    SPEED !  \ each task has it's own bounce speed
    BEGIN
      130 10 DO  PAUSE  I OVER SP.Y VC!   SPEED @ DELAY      LOOP
      10 130 DO  PAUSE  I OVER SP.Y VC!   SPEED @ DELAY  -1 +LOOP
    AGAIN ;

\ INC/DEC byte in VDP RAM
: VC+!  ( n Vaddr -- ) S" TUCK VC@ +  SWAP VC!" EVALUATE ; IMMEDIATE

DECIMAL
: LASER-ON    GEN1 141 HZ 14 DB     GEN2 143 HZ 14 DB ;
: LASER-OFF   GEN1 MUTE             GEN2 MUTE ;


DECIMAL
: EXPLODE ( spr# -- )
    5 NOISE 0 DB         \ impact sound
    LASER-OFF            \ kill the laser beam
    150 MS
    6 NOISE 4 DB
    17 1 DO
        PAUSE
        GEN4 I DB        \ fade impact noise
        I OVER SP.COLOR  \ change spr# color
        3400 TICKS
    LOOP
    DROP 
    SILENT
;


: FIRE_THE_LASER 
    4 NOISE 0 DB                  \ initial shot NOISE
    300 TICKS                     \ brief ontime
    LASER-ON
    4 NOISE 10 DB                 \ HISS noise at cruise volume.
;

VARIABLE YVECT  
VARIABLE XVECT   

: AIM  ( x y --) YVECT !  XVECT ! ; \ sets dir/speed weapon travels 

\ increment/decrement sprite x,y values in VDP RAM 
: SP.X++    ( n spr# -- ) SP.X VC+! ;
: SP.Y++    ( n spr# -- ) SP.Y VC+! ;

: MOVE-WEAPON ( -- )
    XVECT @ #Weapon SP.X++     
    YVECT @ #Weapon SP.Y++ ;

\ *****************************
\ sound loops that run as a task must end with STOP 
\ *****************************

: BLEEP   
    SILENT 
    GEN1  
    31 2
    DO
      200 I * HZ  I DB 
      200 TICKS 
    LOOP  
    MYSELF STOP 
; 

\ : TINK  GEN3 2200 HZ  16 0 DO  GEN3 I DB LOOP  GEN3 MUTE ;
: THUMP    
    GEN4 0 DB 
    16 0 DO  5 NOISE  6 NOISE  5 NOISE  GEN4 I DB  16 TICKS  LOOP  
    GEN4 MUTE ;

: DEFLECTED ( -- ) SILENT  THUMP  MYSELF STOP  ; 

: FADE-BLAST 
    SILENT 
    5 NOISE 
    GEN4
    31 6
    DO PAUSE 
       I DB 50 MS
    LOOP 
;

: Y.DELTA  ( spr1 spr2 -- c) 
    SP.Y VC@ SWAP SP.Y VC@ - 
    DUP 0> IF      2 MIN         EXIT THEN 
    DUP 0< IF  ABS 2 MIN NEGATE  EXIT THEN 
    0 ; ( bounces straight back )

VARIABLE POINTS  
VARIABLE SHOTS 
VARIABLE HITFLAG

: COLLISION ( spr# -- ) \ test ROCK collision with #weapon 
    #Weapon OVER 9 COINC 0= IF  DROP EXIT THEN 
    EXPLOSION 136 CHARDEF32
    HITFLAG ON 
    #Weapon Y.DELTA  YVECT ! \ change y direction proportional to hit 
    XVECT @ NEGATE   XVECT ! \ reverse X direction 
    MOVE-WEAPON MOVE-WEAPON MOVE-WEAPON
    SOUND RESTART 
;

: ENEMY-HIT 
    #Weapon #Bob  10 COINC    
    IF ( we hit Bobby)
        Transparent #Weapon SP.COLOR \ #Weapon goes invisible
        -3 XVECT +!            \ reverse weapon X direction & speed (bounce)
        0 JOB3 SPIN-RATE       \ change Bobby's spin rate
        #Bob EXPLODE           \ make some sound and change Bobby's color
        60 JOB3 SPIN-RATE      \ make Bobby slowdown again
        POINTS 1+!  
        Blue #Bob SP.COLOR           \ reset Bobby's color
        MYSELF STOP            \ we are done with this for now 
    THEN PAUSE  
;

: ASTEROID-HIT 
    #Rock  COLLISION 
    #Rock2 COLLISION 
    #Rock3 COLLISION 
    #Rock4 COLLISION ;

: .SCORE 
   0  23 AT-XY ." Points: " POINTS @ 3 .R 
   15 23 AT-XY ." Ammo: "   SHOTS  @ 3 .R ;

VARIABLE DEAD   \ dead is a message that you are dead 

: SELF-DESTRUCT 
    #Weapon #Bill 11 COINC  
    HITFLAG @ AND    
    IF  
     Transparent #Weapon SP.COLOR
      0 JOB1 SPIN-RATE 
      #Bill EXPLODE 
      5 11 AT-XY ." S H O T   Y E R S E L F"  
      POINTS OFF .SCORE 
      DEAD ON 
    THEN 
;

DECIMAL 
: LAUNCHER  ( -- )
    #Bill POSITION #Weapon LOCATE \ #Weapon on top of #bill sprite 
    FIRE_THE_LASER 
    5 0 AIM 
    SHOTS 1-!  
    HITFLAG OFF 
    COMET 136 CHARDEF32
  \ polling loop for coincidence      
    BEGIN       
      PAUSE
      Red #Weapon SP.COLOR     \ give it a color
      MOVE-WEAPON 
      ENEMY-HIT
      ASTEROID-HIT       
      SELF-DESTRUCT             \ test if weapon bounced back at shooter
      Yellow #Weapon SP.COLOR   \ change color while fire travels
      #Weapon SP.X VC@ 
      248 1 WITHIN              \ test for #Weapon at edge of screen
    UNTIL
    
    Transparent #Weapon SP.COLOR
    LASER-OFF
    FADE-BLAST
    60 JOB3 SPIN-RATE            \ make Bobby slowdown again
    Blue #Bob SP.COLOR           \ reset Bobby's color

    MYSELF STOP  
;

\ ********************
\ Motion Code  runs in separate tasks  
\ ********************
\             Char   Speed ( big is slower)
\             -----  -----
: SPIN-BILL   Billy   60 ROTATOR ;
: SPIN-BOB    Bobby   60 ROTATOR ;
: SPIN-ROCK   Rock    70 ROCK-SPINNER ;

\             Sprite Speed 
\             -----  -----
: BOUNCE-BILL  #Bill  5 BOUNCER ;
: BOUNCE-BOB   #Bob   0 BOUNCER ; \ faster movement, harder to hit
: BOUNCE-ROCK  #Rock 12 BOUNCER ;

\ ********************
\ Assign routines to tasks 
\ ********************
\ *IMPORTANT*
\ When building a binary program it is simplest to ASSIGN code to all tasks.
\ If a task will be assiged later in the program assign it STOP at boot-time.
\ STOP will put itself to sleep and pass control. 

: ASSIGN-JOBS 
    ['] SPIN-BILL   JOB1 ASSIGN
    ['] BOUNCE-BILL JOB2 ASSIGN

    ['] SPIN-BOB    JOB3 ASSIGN
    ['] BOUNCE-BOB  JOB4 ASSIGN

    ['] LAUNCHER    JOB5 ASSIGN   \ this is your blaster 

    ['] SPIN-ROCK   JOB7 ASSIGN 
    ['] DEFLECTED  SOUND ASSIGN 
;

\ RESTART re-assigns the local BOOT variable & resets the stacks before
\ waking the task 
: START-TASKS 
    JOB1  RESTART
    JOB2  RESTART
    JOB3  RESTART 
    JOB4  RESTART 
   \ JOB5  RESTART  \ launcher is re-started by the fire button
    JOB7  RESTART
  \  SOUND RESTART  \ sound is re-started when a collision occurs
;

\ asteroids move under automotion 
: ASTEROID_BELT 
( bug in my negative vertical motion, need the 1)
    1 -21 #Rock  MOTION  
    1 -23 #Rock2 MOTION
    1 -24 #Rock3 MOTION
    1 -25 #Rock4 MOTION
;

\ NOTES 
147 CONSTANT D1 
185 CONSTANT F#1 
220 CONSTANT A1 

: HAPPY
    GEN1 
    D1  HZ 2 DB 80 MS 
    F#1 HZ  80 MS 
    A1  HZ  200 MS 
    MUTE ;

: .TITLE   5  0 AT-XY ." Billy's Space Balls" ;

: SETUP 
    DECIMAL 
    QUIT-ON  DEAD OFF 
    CLEAR
    HAPPY 
    0 19 White 1 COLORS 
    1 SCREEN 
    WRITE-PATTERNS 
    .TITLE .DIRT  .SCORE
    2 MAGNIFY
    CREATE_SPRITES  4 MOVING  ASTEROID_BELT 
    CREATE-TASKS 
    ASSIGN-JOBS
    MULTI 
    START-TASKS 
    AUTOMOTION 
;

\ shoot by waking up the launcher TASK
: FIRE   JOB5 RESTART  650 MS ; 

\ *********************
\  GAME PROCESS  
\ *********************
: GAME 
    SETUP  
    50 SHOTS ! 
    POINTS OFF 
    BEGIN 
      SHOTS @  
    WHILE 
      0 JOYST 1 = IF FIRE THEN .SCORE 
      PAUSE
      DEAD @ IF  WAIT-FOR-QUIT THEN 
    REPEAT 
    6 11 AT-XY ." O U T  O F  A M M O"
    SINGLE SILENT MULTI 
    WAIT-FOR-QUIT
;

: RUN   WARM  GRAPHICS  INIT-MULTI GAME ;

 LOCK
 INCLUDE DSK1.SAVESYS 
 ' RUN SAVESYS DSK7.BILLYBALL

