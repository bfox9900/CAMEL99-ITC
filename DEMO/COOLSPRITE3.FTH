\ EXTENDED BASIC to CAMEL99 Forth demo BJFox 2019
\ forth style translation from BASIC uses no VARIABLES 

\ Source:  Smart Programming Guide for Sprites
\          by Craig Miller
\          (c) 1983 by Miller Graphics
\ 100 CALL CLEAR
\ 110 CALL SCREEN(2)
\ 120 CALL CHAR(46,"0000001818")
\ 130 CALL SPRITE(#2,94,16,180,1,0,5)
\ 140 FOR N=0 TO 25
\ 150     X=RND*192+1
\ 160     Y=RND*255+1
\ 170     CALL SPRITE(#3,65+N,16,Y/2+1,X+1)
\ 180     CALL SOUND(-60,660,8)
\ 190     CALL POSITION(#3,Y,X,#2,R,C)
\ 200     CALL SPRITE(#1,46,16,R,C,(Y-R)*.49,(X-C)*.49)
\ 210     CALL SOUND(476,-3,14)
\ 220     CALL SOUND(120,110,6)
\ 230     CALL DELSPRITE(#1)
\ 240     CALL PATTERN(#3,35)
\ 250     CALL SOUND(100,220,6)
\ 260 NEXT N
\ 270 GOTO 140

\ Camel99 kernel is bare-bones. 
\ Extras must be compiled into system
NEEDS .S     FROM DSK1.TOOLS
NEEDS MOTION FROM DSK1.AUTOMOTION
NEEDS RND    FROM DSK1.RANDOM
NEEDS DB     FROM DSK1.SOUND

\ character definition for the bullet 
CREATE ABULLET HEX 0000 , 0018 , 1800 , 0000 ,

DECIMAL
\ name the sprites 
 1 CONSTANT AMMO    2 CONSTANT TURRET   3 CONSTANT TARGET

\ Name the colors
 2 CONSTANT BLACK   5 CONSTANT BLUE    16 CONSTANT WHITE

\ words to make it more like BASIC 
: SOUND1   ( t Hz db -- ) GEN1  DB  HZ  MS  MUTE ;
: ?BREAK   ?TERMINAL IF  STOPMOTION CR ." BREAK"  ABORT  THEN ;

\ return random coordinates 
: RNDX  ( -- x) 255 RND 1+ ;
: RNDY  ( -- y) 192 RND 1+ ;

: TURRET-SPRITE 
\    ascii    colr x  y   spr# 
    [CHAR] ^ WHITE 1 180 TURRET SPRITE   
    5 0 TURRET MOTION ;

: TARGET-SPRITE ( char --) 
\   colr     x       y        spr# 
    WHITE  RNDX 1+  RNDY 2/  TARGET SPRITE ;    

\ function computes motion vector between 2 SPRITES
: DELTA ( x y x2 y2  -- x' y')  
        ROT  - 2/  >R   \ delta Y pushed to Rstack 
        SWAP - 2/       \ delta X    
        R> ;            \ bring back delta Y  

: DELSPRITE ( spr# -- ) 0 SWAP SP.PAT VC! ;

: SHOOT 
\ next line sets the motion vector for the AMMO sprite
\ by reading the sprite positions and computing the delta
    TURRET POSITION  TARGET POSITION DELTA  AMMO MOTION

\ generate noise using sound chip API
    2 NOISE -14 DB 430 MS MUTE

    120 110 -6 SOUND1 
    AMMO DELSPRITE
    [CHAR] # TARGET PATTERN
    100 220 -6 SOUND1    
;

: RUN 
    CLEAR  
    BLUE SCREEN 
    10 0 AT-XY ." Camel99 Forth"
    ABULLET [CHAR] . CHARDEF
    TURRET-SPRITE 
    AUTOMOTION
    BEGIN 
        25 0 
        DO
        \ put target sprite on the screen with a sound     
            [CHAR] A  I +  TARGET-SPRITE 
            50 660 8 SOUND1

        \ put the AMMO sprite at the turret position 
            [CHAR] . WHITE TURRET POSITION AMMO SPRITE  
            SHOOT 
           
            ?BREAK 
        LOOP
    AGAIN ;

