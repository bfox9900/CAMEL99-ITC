\ KIBBIT.FTH   May 25 2024 ported to Camel99 Forth 

\ Originally written by:
\ Greg Goodwin, TI Hoosier's User Group, circa 1980s

\ Translated to Camel99 Forth 
NEEDS CASE   FROM DSK1.CASE 
NEEDS PLOT   FROM DSK1.GRAPHICS2 
NEEDS SPRITE FROM DSK1.SPRITES2   ( for use with Graphics2)
NEEDS JOYST  FROM DSK1.JOYST


HEX 
\ ================ KIBBIT BEGINS HERE =====================

\ define the sprite shape data but give them a name
CREATE $PENCIL ( -- addr ) F0E0 , E090 , 0804 , 0000 ,
CREATE $ERASER ( -- addr ) 0010 , 387C , 3E1E , 0C00 ,
CREATE $BRUSH  ( -- addr ) 8080 , C060 , 6010 , 0800 ,
CREATE $ROLLER ( -- addr ) 007E , 7E02 , 1E10 , 1010 ,

DECIMAL
   0 CONSTANT POINTER \ familiar sprite name like BASIC 

: INIT_KIBBIT
   GRAPHICS2    \ set bitmap mode before anything else 
   DELALL       \ INIT the sprite memory 

\ initialize turtle sprite chars
\  data   bytes char 
   $PENCIL 8    138 SP.SHAPE
   $ERASER 8    139 SP.SHAPE
   $ROLLER 8    140 SP.SHAPE

\   colr char  X  Y spr#    
     5   138  22 22  0 SPRITE ;

: TEST  
   INIT_KIBBIT 
   BEGIN ?TERMINAL UNTIL 
   TEXT ;   

\ JOYST Output decoding 
HEX 
 01 CONSTANT Fire
 02 CONSTANT Left
 04 CONSTANT Right
 08 CONSTANT Down
 10 CONSTANT Up
 0A CONSTANT Down/left
 0C CONSTANT Down/right
 12 CONSTANT Up/left
 14 CONSTANT Up/right

DECIMAL 
\ add byte to a byte in VDP memory 
: VC+!  ( byte Vaddr -- ) DUP>R VC@ +  R> VC! ;

0 CONSTANT #1  \ the sprite name 

\ these words alter the sprite position by changing the fields in VDP memory 
: GOUP    -1 #1 SP.Y VC+! ; 
: GODOWN   1 #1 SP.Y VC+! ;
: GOLEFT  -1 #1 SP.X VC+! ;
: GORIGHT  1 #1 SP.X VC+! ;

: MOVE_BRUSH 
    0 JOYST 
    CASE 
        Left  OF  GOLEFT         ENDOF
        Right OF  GORIGHT        ENDOF
        Down  OF  GODOWN         ENDOF
        Up    OF  GOUP           ENDOF

    Down/left OF  GODOWN GOLEFT  ENDOF 
   Down/right OF  GODOWN GORIGHT ENDOF 
    Up/left   OF  GOUP   GOLEFT  ENDOF 
    Up/right  OF  GOUP   GORIGHT ENDOF 
    ENDCASE  
;

: TEST2  
    INIT_KIBBIT
    BEGIN  
      MOVE_BRUSH 
      ?TERMINAL 
    UNTIL 
    TEXT ;

: DOPENCIL   PENCIL IS STYLUS   138 #1 SP.PAT VC! ; 
: DOERASE    ERASER IS STYLUS   139 #1 SP.PAT VC! ;
: DOTOGGLE   BRUSH  IS STYLUS   140 #1 SP.PAT VC! ; 

: CHANGE_BRUSH 
    KEY? 
    CASE
      [CHAR] D OF  DOPENCIL     ENDOF 
      [CHAR] E OF  DOERASE       ENDOF 
      [CHAR] T OF  DOTOGGLE      ENDOF 
      [CHAR] C OF  INIT_KIBBIT   ENDOF 
    ENDCASE   
;

: TEST3  
    INIT_KIBBIT
    BEGIN  
      MOVE_BRUSH 
      CHANGE_BRUSH
      ?TERMINAL 
    UNTIL 
    TEXT ;


\ draw only if fire button is pushed down
: ?DRAW ( -- ) JOYST 1 AND IF  #1 POSITION PLOT  THEN ;

: KIBBIT
   INIT_TURTLE
   BEGIN
     MOVE_BRUSH 
     CHANGE_BRUSH
     ?DRAW
     ?TERMINAL   
   UNTIL
   TEXT ;  

\ KIBBIT            \ start program